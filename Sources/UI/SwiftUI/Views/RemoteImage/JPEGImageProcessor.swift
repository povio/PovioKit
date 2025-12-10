//
//  JPEGImageProcessor.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Kingfisher
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// An image processor that compresses images to JPEG format to reduce memory footprint.
///
/// This processor converts images to JPEG format with a specified compression quality.
/// It's useful for reducing memory usage, especially when combined with downsampling.
///
/// ## Example
/// ```swift
/// let processor = DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
///     |> JPEGImageProcessor(compressionQuality: 0.8)
/// RemoteImage(url: imageURL)
///     .processor(processor)
/// ```
public struct JPEGImageProcessor: ImageProcessor {
  /// The compression quality, ranging from 0.0 (maximum compression, lowest quality)
  /// to 1.0 (no compression, highest quality).
  public let compressionQuality: CGFloat
  
  /// A unique identifier for this processor.
  public let identifier: String
  
  /// Creates a JPEG image processor with the specified compression quality.
  ///
  /// - Parameter compressionQuality: The compression quality (0.0 to 1.0).
  ///   Default is 0.8, which provides a good balance between file size and quality.
  ///   - 0.9-1.0: High quality, larger file size
  ///   - 0.7-0.8: Balanced (recommended)
  ///   - 0.5-0.6: High compression, smaller file size
  public init(compressionQuality: CGFloat = 0.8) {
    self.compressionQuality = max(0.0, min(1.0, compressionQuality))
    self.identifier = "com.povio.JPEGImageProcessor(\(compressionQuality))"
  }
  
  public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
    switch item {
    case .image(let image):
      #if canImport(UIKit)
      guard let jpegData = image.jpegData(compressionQuality: compressionQuality),
            let compressedImage = UIImage(data: jpegData) else {
        return image
      }
      return compressedImage
      #elseif canImport(AppKit)
      guard let tiffData = image.tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffData),
            let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality]),
            let compressedImage = NSImage(data: jpegData) else {
        return image
      }
      return compressedImage
      #else
      return image
      #endif
      
    case .data(let data):
      #if canImport(UIKit)
      return UIImage(data: data)
      #elseif canImport(AppKit)
      return NSImage(data: data)
      #else
      return nil
      #endif
    }
  }
}

