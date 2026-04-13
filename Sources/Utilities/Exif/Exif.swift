//
//  Exif.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 16/02/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import ImageIO

/// A wrapper around Image I/O framework APIs that can be used to modify EXIF and other image metadata without recompressing the image data.
public final class Exif {
  private let source: ExifImageSource
  
  public init(source: ExifImageSource) {
    self.source = source
  }
}

// MARK: - Public Methods
public extension Exif {
  /// Read EXIF metadata from the provided image source
  /// - Returns: Dictionary with EXIF values as a Result
  func read() throws -> [String: Any] {
    guard let imageSource = getImageSource() else {
      throw ExifError.createImageSource
    }
    guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
      throw ExifError.getImageProperties
    }
    
    return imageProperties
  }
    
  /// Update EXIF metadata with the new values
  ///
  /// Keys for the new values must be part of the [EXIF Dictionary Keys](https://developer.apple.com/documentation/imageio/exif_dictionary_keys)
  /// - Parameter newValue: Dictionary with the new EXIF values
  /// - Returns: New image Data as a Result
  func update(_ newValue: [CFString: String]) throws -> Data {
    guard let imageSource = getImageSource() else {
      throw ExifError.createImageSource
    }
    
    guard let UTI: CFString = CGImageSourceGetType(imageSource) else {
      throw ExifError.getImageType
    }
    
    let imageData: CFMutableData = CFDataCreateMutable(nil, 0)
    guard let destination = CGImageDestinationCreateWithData(imageData as CFMutableData, UTI, 1, nil) else {
      throw ExifError.createImageDestination
    }
    
    var mutableMetadata: CGMutableImageMetadata
    if let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) {
      mutableMetadata = CGImageMetadataCreateMutableCopy(imageMetadata) ?? CGImageMetadataCreateMutable()
    } else {
      mutableMetadata = CGImageMetadataCreateMutable()
    }
    
    for item in newValue {
      CGImageMetadataSetValueMatchingImageProperty(mutableMetadata,
                                                   kCGImagePropertyExifDictionary,
                                                   item.key,
                                                   item.value as CFString)
    }
    
    let options: [String : Any] = [kCGImageDestinationMetadata as String : mutableMetadata,
                                  kCGImageDestinationMergeMetadata as String : true]
    guard CGImageDestinationCopyImageSource(destination, imageSource, options as CFDictionary, nil) else {
      throw ExifError.copyImageSource
    }
    
    return imageData as Data
  }
}

// MARK: - Private Methods
private extension Exif {
  func getImageSource() -> CGImageSource? {
    var imageSource: CGImageSource?
    switch source {
    case .url(let url):
      imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
    case .data(let data):
      imageSource = CGImageSourceCreateWithData(data as CFData, nil)
    }
    return imageSource
  }
}
