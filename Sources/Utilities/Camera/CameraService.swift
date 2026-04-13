//
//  CameraService.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation.AVMediaFormat
import PovioKitCore

public struct CameraService {
  /* see extension bellow for implementation */
  public init() { }
}

// MARK: - Public methods
public extension CameraService {
  /// Check if app is authorized to use camera or not. For the first time this method will ask user for permission.
  func requestCameraAuthorization() async -> Bool {
    let mediaType = Camera.MediaType.video
    let authStatus = authorizationStatus(forType: mediaType)

    if authStatus == .notDetermined {
      let granted = await AVCaptureDevice.requestAccess(for: .video)
      return granted
    }
    
    return authStatus == .authorized
  }
  
  /// Returns current authorization status
  var authStatus: Camera.CameraAuthorizationStatus {
    authorizationStatus(forType: .video)
  }
}

// MARK: - Private methods
private extension CameraService {
  /// Returns current camera authorization status
  func authorizationStatus(forType mediaType: Camera.MediaType) -> Camera.CameraAuthorizationStatus {
    switch AVCaptureDevice.authorizationStatus(for: mediaType.asAVMediaType) {
    case .authorized:
      return .authorized
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .notDetermined
    @unknown default:
      Logger.error("Camera device in an unknown state!")
      return .denied
    }
  }
}
