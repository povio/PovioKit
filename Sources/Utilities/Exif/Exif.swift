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
    
    for (key, value) in newValue {
      let success = CGImageMetadataSetValueMatchingImageProperty(
        mutableMetadata,
        kCGImagePropertyExifDictionary,
        key,
        value as CFString
      )
      guard success else {
        throw ExifError.setMetadataValue(key: key as String)
      }
    }
    
    let options: [String : Any] = [kCGImageDestinationMetadata as String : mutableMetadata,
                                  kCGImageDestinationMergeMetadata as String : true]
    guard CGImageDestinationCopyImageSource(destination, imageSource, options as CFDictionary, nil) else {
      throw ExifError.copyImageSource
    }
    if containsExifValues(newValue, in: imageData as Data) {
      return imageData as Data
    }
    
    // `CGImageDestinationCopyImageSource` succeeds but silently drops the new
    // metadata for some formats (notably HEIC and TIFF). Fall back to
    // re-encoding the image with the metadata attached.
    guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
      throw ExifError.copyImageSource
    }
    let reencodedData: CFMutableData = CFDataCreateMutable(nil, 0)
    guard let reencodeDestination = CGImageDestinationCreateWithData(reencodedData, UTI, 1, nil) else {
      throw ExifError.createImageDestination
    }
    CGImageDestinationAddImageAndMetadata(reencodeDestination, image, mutableMetadata, nil)
    guard CGImageDestinationFinalize(reencodeDestination) else {
      throw ExifError.copyImageSource
    }
    return reencodedData as Data
  }
}

// MARK: - Private Methods
private extension Exif {
  func containsExifValues(_ values: [CFString: String], in data: Data) -> Bool {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
          let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any] else { return false }
    return values.keys.allSatisfy { exif[$0] != nil }
  }

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
