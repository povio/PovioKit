//
//  Camera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation
import Foundation

public class Camera: NSObject, @unchecked Sendable {
  // MARK: - Threading model
  //
  // All mutation of `session` — both the lifecycle (`startRunning()` /
  // `stopRunning()`) and the topology (`beginConfiguration()` /
  // `addInput`/`removeInput`/`addOutput`, reached via `configure()` in
  // subclasses) — must happen on `sessionQueue`. Use the `onSessionQueue`
  // helper below so callers don't need to open-code the re-entrancy check.
  //
  // `cameraPosition` and `deviceType` feed the `device` computed property,
  // which is read both on `sessionQueue` (inside `configure()`) and off it
  // (e.g. `isTorchAvailable` from the main thread). They are therefore
  // guarded by `stateLock`, so reads and writes are atomic regardless of
  // the calling thread.
  //
  // Marked `@unchecked Sendable` to allow the camera hierarchy to
  // participate in Swift Concurrency. The `@unchecked` is load-bearing
  // because `previewLayer` (an `AVCaptureVideoPreviewLayer`) is a stored
  // property without compile-time Sendable guarantees.
  static let sessionQueueKey = DispatchSpecificKey<Void>()
  var device: AVCaptureDevice? {
    switch cameraPosition {
    case .back:
      return isCameraAvailable(for: deviceType, position: .back) 
      ? AVCaptureDevice.default(deviceType, for: .video, position: .back)
      : nil
    case .front:
      return isCameraAvailable(for: deviceType, position: .front) 
      ? AVCaptureDevice.default(deviceType, for: .video, position: .front)
      : nil
    }
  }
  let session = AVCaptureSession()
  // Communicate with the session and other session objects on this queue.
  let sessionQueue = DispatchQueue(label: "com.poviokit.camera")
  public lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    
    return previewLayer
  }()
  public let cameraService: CameraService
  /// The currently attached device input, swapped out on each reconfigure.
  var deviceInput: AVCaptureDeviceInput?

  private let stateLock = NSLock()
  private var _deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
  private var _cameraPosition: CameraPosition = .back

  public var deviceType: AVCaptureDevice.DeviceType {
    get { stateLock.withLock { _deviceType } }
    set { stateLock.withLock { _deviceType = newValue } }
  }
  var cameraPosition: CameraPosition {
    get { stateLock.withLock { _cameraPosition } }
    set { stateLock.withLock { _cameraPosition = newValue } }
  }

  init(with cameraService: CameraService = CameraService()) {
    self.cameraService = cameraService
    super.init()
    sessionQueue.setSpecific(key: Self.sessionQueueKey, value: ())
  }
  
  deinit {
    stopSession()
  }

  /// Runs `work` on `sessionQueue` and returns its result. Re-entrant via
  /// `sessionQueueKey`, so session-owned code that is already executing on
  /// `sessionQueue` (e.g. inside `startSession`'s async block) can call
  /// helpers that are themselves annotated with this helper without
  /// deadlocking.
  func onSessionQueue<T>(_ work: () throws -> T) rethrows -> T {
    if DispatchQueue.getSpecific(key: Self.sessionQueueKey) != nil {
      return try work()
    } else {
      return try sessionQueue.sync(execute: work)
    }
  }

  /// Reconfigures the capture session on `sessionQueue`: swaps in a fresh
  /// `AVCaptureDeviceInput` for the current `device` and lets the caller
  /// attach its output(s). Serialized with `startSession()` / `stopSession()`
  /// and with concurrent reconfigures triggered by `setCameraPosition(_:)`
  /// or `setDeviceType(_:)`.
  ///
  /// - Parameters:
  ///   - preset: Optional session preset applied within the configuration block.
  ///   - prepareDevice: Hook to configure the device before the input is
  ///     attached (e.g. focus mode). Runs before `beginConfiguration()`.
  ///   - configureOutputs: Attaches output(s) to the session. Runs inside the
  ///     configuration block, after the input has been added.
  func reconfigureSession(
    preset: AVCaptureSession.Preset? = nil,
    prepareDevice: (AVCaptureDevice) throws -> Void = { _ in },
    configureOutputs: (AVCaptureDevice) throws -> Void
  ) throws {
    try onSessionQueue {
      guard let device else { throw Camera.Error.unavailable }
      try prepareDevice(device)

      session.beginConfiguration()
      defer { session.commitConfiguration() }

      if let preset {
        session.sessionPreset = preset
      }

      if let previousDeviceInput = deviceInput {
        session.removeInput(previousDeviceInput)
      }

      guard let deviceInput = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(deviceInput) else {
        throw Camera.Error.missingInput
      }
      self.deviceInput = deviceInput
      session.addInput(deviceInput)

      try configureOutputs(device)
    }
  }
}

// MARK: - Public Methods
public extension Camera {
  var isTorchAvailable: Bool {
    device.map { $0.hasTorch && $0.isTorchAvailable } ?? false
  }
  
#if os(iOS)
  var virtualDeviceSwitchOverVideoZoomFactors: [Int] {
    device?
      .virtualDeviceSwitchOverVideoZoomFactors
      .compactMap { $0.intValue } ?? []
  }
#endif
  
  func requestAuthorizationStatus() async -> Bool {
    await cameraService.requestCameraAuthorization()
  }
  
  func startSession() {
    sessionQueue.async {
      guard !self.session.isRunning else { return }
      self.session.startRunning()
    }
  }
  
  func stopSession() {
    onSessionQueue {
      guard self.session.isRunning else { return }
      self.session.stopRunning()
    }
    try? setTorch(on: false) // just in case but flashlight is automatically turned off when session is stopped
  }
  
  func toggleTorch() throws {
    try setTorch(on: !(device?.isTorchActive ?? true))
  }
  
#if os(iOS)
  func setZoom(_ zoomFactor: CGFloat,
               animated: Bool = true,
               rate: Float = 5) throws {
    guard let device else { return }
    let clampedZoomFactor = max(device.minAvailableVideoZoomFactor, min(zoomFactor, device.maxAvailableVideoZoomFactor))
    try device.lockForConfiguration()
    defer { device.unlockForConfiguration() }
    if animated {
      device.ramp(toVideoZoomFactor: clampedZoomFactor, withRate: rate)
    } else {
      device.videoZoomFactor = clampedZoomFactor
    }
  }
#endif
  
  /// Check if camera is available on device
  func isCameraAvailable(
    for deviceType: AVCaptureDevice.DeviceType,
    position: Camera.CameraPosition
  ) -> Bool {
    !AVCaptureDevice
      .DiscoverySession(
        deviceTypes: [deviceType],
        mediaType: .video,
        position: position.asAVCaptureDevicePosition)
      .devices
      .isEmpty
  }
}

// MARK: - Private Methods
private extension Camera {
  func setTorch(on: Bool) throws {
    guard let device = device, device.hasTorch, device.isTorchAvailable else { return }
    try device.lockForConfiguration()
    defer { device.unlockForConfiguration() }
    switch on {
    case true:
      try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
    case false:
      device.torchMode = .off
    }
  }
}
