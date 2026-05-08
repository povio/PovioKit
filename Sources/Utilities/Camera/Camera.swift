//
//  Camera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation

public class Camera: NSObject, @unchecked Sendable {
  // MARK: - Threading model
  //
  // All mutation of `session` — both the lifecycle (`startRunning()` /
  // `stopRunning()`) and the topology (`beginConfiguration()` /
  // `addInput`/`removeInput`/`addOutput`, reached via `configure()` in
  // subclasses) — must happen on `sessionQueue`. Use the `onSessionQueue`
  // helper below so callers don't need to open-code the re-entrancy check.
  //
  // `cameraPosition` and `deviceType` are read inside `configure()` (which
  // now runs on `sessionQueue`), but their setters are still plain stored
  // properties with no locking. Consumers are expected to mutate them from
  // a single thread (typically the main thread via `setCameraPosition(_:)`
  // or `setDeviceType(_:)` on a subclass); mutating them concurrently from
  // multiple threads is undefined.
  //
  // Marked `@unchecked Sendable` to allow the camera hierarchy to
  // participate in Swift Concurrency. The `@unchecked` is load-bearing
  // because `previewLayer`, `cameraPosition`, and `deviceType` are stored
  // properties without compile-time Sendable guarantees.
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
  public var deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
  var cameraPosition: CameraPosition = .back
  
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
