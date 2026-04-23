//
//  ExifError.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 17/02/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public enum ExifError: Error, Hashable, Sendable {
  case createImageSource
  case getImageProperties
  case getImageType
  case createImageDestination
  case copyImageSource
  /// `CGImageMetadataSetValueMatchingImageProperty` returned `false` for the
  /// specified EXIF key; the update was rejected by ImageIO.
  case setMetadataValue(key: String)
}
