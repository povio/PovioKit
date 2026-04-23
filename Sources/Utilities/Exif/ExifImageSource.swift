//
//  ExifImageSource.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 17/02/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public enum ExifImageSource: Sendable {
  case url(URL)
  /// Keep in mind that some image formats are not lossless and could lose quality.
  /// When dealing with PNGs, you could load it with `UIImage(named:` and convert it to Data with `pngData()` method. This will persist in the quality since PNG is a lossless format.
  /// However, this isn't true for the JPG format which isn't lossless. You need to load Data directly from the file to avoid losing on quality with `Data(contentsOf: URL)`.
  case data(Data)
}
