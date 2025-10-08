//
//  ExifError.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 17/02/2023.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public enum ExifError: Error {
  case createImageSource
  case getImageProperties
  case getImageType
  case createImageDestination
  case copyImageSource
}
