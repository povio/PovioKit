//
//  PhotoCamera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import AVFoundation
import UIKit

public protocol PhotoCameraDelegate: AnyObject {
  func photoCamera(_ photoCamera: PhotoCamera, didTakePhoto image: UIImage)
  func photoCamera(_ photoCamera: PhotoCamera, didTriggerError error: Camera.Error)
}

public class PhotoCamera: Camera {
  public weak var delegate: PhotoCameraDelegate?
  private let photoOutput = AVCapturePhotoOutput()
  private var deviceInput: AVCaptureDeviceInput?
  
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
  
  func takePhoto(
    isHighResolutionPhotoEnabled: Bool = true,
    qualityPrioritization: AVCapturePhotoOutput.QualityPrioritization = .balanced,
    flashMode: AVCaptureDevice.FlashMode = .auto,
    videoOrientation: AVCaptureVideoOrientation? = nil
  ) {
    let videoOrientation = (videoOrientation != nil) 
    ? videoOrientation
    : previewLayer.connection?.videoOrientation
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
        photoOutputConnection.videoOrientation = videoOrientation ?? .portrait
      }
      if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
      }
      
      self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
  }
  
  func takePhoto(
    with photoSettings: AVCapturePhotoSettings,
    videoOrientation: AVCaptureVideoOrientation? = nil
  ) {
    let videoOrientation = (videoOrientation != nil) ? videoOrientation : previewLayer.connection?.videoOrientation
    sessionQueue.async {
      guard self.session.isRunning else {
        DispatchQueue.main.async { self.delegate?.photoCamera(self, didTriggerError: .missingSession) }
        return
      }
      
      if let photoOutputConnection = self.photoOutput.connection(with: .video) {
        photoOutputConnection.videoOrientation = videoOrientation ?? .portrait
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
  func configure() throws {
    guard let device = device else { throw Camera.Error.unavailable }
    
    session.beginConfiguration()
    session.sessionPreset = .photo
    
    // remove previous input if any
    if let previousDeviceInput = self.deviceInput {
      session.removeInput(previousDeviceInput)
    }
    
    // prepare input
    guard let deviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(deviceInput) else {
      throw Camera.Error.missingInput
    }
    
    self.deviceInput = deviceInput
    session.addInput(deviceInput)
    
    // prepare output
    if !session.outputs.contains(photoOutput) {
      guard session.canAddOutput(photoOutput) else {
        throw Camera.Error.missingOutput
      }
      session.addOutput(photoOutput)
    }
    
    session.commitConfiguration()
  }
}

#endif
