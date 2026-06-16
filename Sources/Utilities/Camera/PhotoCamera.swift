//
//  PhotoCamera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
// `AVCapturePhotoSettings` is not annotated `Sendable` by AVFoundation even
// though it's safe to hand across queues in the way we do here. Import as
// `@preconcurrency` so those `Sendable`-related warnings don't leak into
// downstream targets.
@preconcurrency import AVFoundation
import CoreGraphics
import UIKit

public protocol PhotoCameraDelegate: AnyObject {
  func photoCamera(_ photoCamera: PhotoCamera, didTakePhoto image: UIImage)
  func photoCamera(_ photoCamera: PhotoCamera, didTriggerError error: Camera.Error)
}

public class PhotoCamera: Camera, @unchecked Sendable {
  public weak var delegate: PhotoCameraDelegate?
  private let photoOutput = AVCapturePhotoOutput()

  public init(delegate: PhotoCameraDelegate? = nil) {
    super.init()
    self.delegate = delegate
  }
}

// MARK: - Public Methods
public extension PhotoCamera {
  func prepare() async throws {
    try configure()
  }
  
  func setCameraPosition(_ position: CameraPosition) throws {
    guard cameraPosition != position else { return }
    cameraPosition = position
    try configure()
  }
  
  func setDeviceType(_ type: AVCaptureDevice.DeviceType) throws {
    guard deviceType != type, isCameraAvailable(for: type, position: cameraPosition) else { return }
    deviceType = type
    try configure()
  }
  
  /// Captures a photo.
  ///
  /// - Parameters:
  ///   - isHighResolutionPhotoEnabled: Whether to capture at the output's
  ///     `maxPhotoDimensions` instead of the zero-size default.
  ///   - qualityPrioritization: Relative balance between speed and quality.
  ///   - flashMode: Flash policy for this capture, applied only when the
  ///     output supports the requested mode.
  ///   - videoRotationAngle: Rotation angle (in degrees) to apply to the
  ///     capture connection. When `nil`, the preview layer's current angle
  ///     is used. Typical values are `0`, `90`, `180`, `270`. When the
  ///     computed angle is unsupported by the connection, portrait (`90`)
  ///     is used as a fallback — matching the pre-7.0 `.portrait` default.
  ///
  /// > Note: Replaces the previous `videoOrientation: AVCaptureVideoOrientation?`
  ///   parameter, which relied on APIs deprecated in iOS 17.
  func takePhoto(
    isHighResolutionPhotoEnabled: Bool = true,
    qualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced,
    flashMode: AVCaptureDevice.FlashMode = .auto,
    videoRotationAngle: CGFloat? = nil
  ) {
    let requestedRotationAngle = videoRotationAngle ?? previewLayer.connection?.videoRotationAngle
    sessionQueue.async {
      guard self.session.isRunning else {
        DispatchQueue.main.async {
          self.delegate?.photoCamera(self, didTriggerError: .missingSession)
        }
        return
      }
      
      let photoSettings = AVCapturePhotoSettings()
      photoSettings.maxPhotoDimensions = isHighResolutionPhotoEnabled ? self.photoOutput.maxPhotoDimensions : .init(width: 0, height: 0)
      photoSettings.photoQualityPrioritization = qualityPrioritization
      if self.photoOutput.supportedFlashModes.contains(flashMode) {
        photoSettings.flashMode = flashMode
      }
      if let photoOutputConnection = self.photoOutput.connection(with: .video) {
        Self.applyRotationAngle(requestedRotationAngle, to: photoOutputConnection)
      }
      if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
      }
      
      self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
  }
  
  func takePhoto(
    with photoSettings: AVCapturePhotoSettings,
    videoRotationAngle: CGFloat? = nil
  ) {
    let requestedRotationAngle = videoRotationAngle ?? previewLayer.connection?.videoRotationAngle
    sessionQueue.async {
      guard self.session.isRunning else {
        DispatchQueue.main.async { self.delegate?.photoCamera(self, didTriggerError: .missingSession) }
        return
      }
      
      if let photoOutputConnection = self.photoOutput.connection(with: .video) {
        Self.applyRotationAngle(requestedRotationAngle, to: photoOutputConnection)
      }
      
      self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
  }
}

// MARK: - AVCapturePhotoCapture Delegate
extension PhotoCamera: AVCapturePhotoCaptureDelegate {
  public func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Swift.Error?
  ) {
    guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
      DispatchQueue.main.async { self.delegate?.photoCamera(self, didTriggerError: .invalidImage) }
      return
    }
    DispatchQueue.main.async { self.delegate?.photoCamera(self, didTakePhoto: image) }
  }
}

// MARK: - Private Methods
private extension PhotoCamera {
  /// Portrait orientation expressed as a `videoRotationAngle` — the default
  /// used by pre-iOS-17 code via `AVCaptureVideoOrientation.portrait`.
  static var defaultPortraitRotationAngle: CGFloat { 90 }
  
  /// Applies the requested rotation angle to a capture connection, falling
  /// back to portrait when either no angle was requested or the connection
  /// reports the requested angle as unsupported. Silently no-ops when
  /// neither the requested angle nor the portrait fallback is accepted.
  static func applyRotationAngle(_ requestedAngle: CGFloat?, to connection: AVCaptureConnection) {
    let candidates = [requestedAngle, defaultPortraitRotationAngle].compactMap { $0 }
    for angle in candidates where connection.isVideoRotationAngleSupported(angle) {
      connection.videoRotationAngle = angle
      return
    }
  }
  
  /// Reconfigures the capture session, attaching the photo output. See
  /// ``Camera/reconfigureSession(preset:prepareDevice:configureOutputs:)``.
  func configure() throws {
    try reconfigureSession(preset: .photo) { _ in
      if !session.outputs.contains(photoOutput) {
        guard session.canAddOutput(photoOutput) else {
          throw Camera.Error.missingOutput
        }
        session.addOutput(photoOutput)
      }
    }
  }
}

#endif
