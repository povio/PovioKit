//
//  Camera+PovioKit.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 21/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation

public extension Camera {
  enum CameraPosition: Sendable {
    case back
    case front
  }

  enum CameraAuthorizationStatus: Sendable {
    case authorized
    case denied
    case notDetermined
  }

  enum MediaType: Sendable {
    case video
    case audio
  }
  
  enum Error: Swift.Error, Sendable {
    case unavailable
    case missingSession
    case missingInput
    case missingOutput
    case missingMetadata
    case invalidImage
  }
}

extension Camera.CameraPosition {
  var asAVCaptureDevicePosition: AVCaptureDevice.Position {
    switch self {
    case .back:
      return .back
    case .front:
      return .front
    }
  }
}

extension Camera.MediaType {
  var asAVMediaType: AVMediaType {
    switch self {
    case .video:
      return .video
    case .audio:
      return .audio
    }
  }
}
