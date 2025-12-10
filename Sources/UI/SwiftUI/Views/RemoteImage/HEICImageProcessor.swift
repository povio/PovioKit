//
//  HEICImageProcessor.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Kingfisher
#if canImport(UIKit)
import UIKit
import ImageIO
import CoreServices
#elseif canImport(AppKit)
import AppKit
import ImageIO
import CoreServices
#endif

/// An image processor that compresses images to HEIC format to reduce memory footprint.
///
/// HEIC (High Efficiency Image Container) provides superior compression compared to JPEG,
/// typically achieving 50% smaller file sizes at similar quality levels. This processor
/// is ideal for iOS and macOS applications where maximum compression efficiency is desired.
///
/// **Note:** HEIC format is supported on iOS 11+ and macOS 10.13+. On older systems,
/// the processor will fall back to returning the original image.
///
/// ## Example
/// ```swift
/// let processor = DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
///     |> HEICImageProcessor(compressionQuality: 0.8)
/// RemoteImage(url: imageURL)
///     .processor(processor)
/// ```
public struct HEICImageProcessor: ImageProcessor {
  /// The compression quality, ranging from 0.0 (maximum compression, lowest quality)
  /// to 1.0 (no compression, highest quality).
  public let compressionQuality: CGFloat
  
  /// A unique identifier for this processor.
  public let identifier: String
  
  /// Creates a HEIC image processor with the specified compression quality.
  ///
  /// - Parameter compressionQuality: The compression quality (0.0 to 1.0).
  ///   Default is 0.8, which provides a good balance between file size and quality.
  ///   - 0.9-1.0: High quality, larger file size
  ///   - 0.7-0.8: Balanced (recommended)
  ///   - 0.5-0.6: High compression, smaller file size
  public init(compressionQuality: CGFloat = 0.8) {
    self.compressionQuality = max(0.0, min(1.0, compressionQuality))
    self.identifier = "com.povio.HEICImageProcessor(\(compressionQuality))"
  }
  
  public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
    switch item {
    case .image(let image):
      #if canImport(UIKit)
      return convertToHEIC(image: image, quality: compressionQuality) ?? image
      #elseif canImport(AppKit)
      return convertToHEIC(image: image, quality: compressionQuality) ?? image
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
  
  #if canImport(UIKit)
  private func convertToHEIC(image: UIImage, quality: CGFloat) -> UIImage? {
    guard let imageData = image.heicData(compressionQuality: quality),
          let heicImage = UIImage(data: imageData) else {
      return nil
    }
    return heicImage
  }
  #elseif canImport(AppKit)
  private func convertToHEIC(image: NSImage, quality: CGFloat) -> NSImage? {
    guard let imageData = image.heicData(compressionQuality: quality),
          let heicImage = NSImage(data: imageData) else {
      return nil
    }
    return heicImage
  }
  #endif
}

#if canImport(UIKit)
private extension UIImage {
  func heicData(compressionQuality: CGFloat) -> Data? {
    guard let mutableData = CFDataCreateMutable(nil, 0),
          let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
          let cgImage = self.cgImage else {
      return nil
    }
    
    let options: [CFString: Any] = [
      kCGImageDestinationLossyCompressionQuality: compressionQuality
    ]
    
    CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
      return nil
    }
    
    return mutableData as Data
  }
}
#elseif canImport(AppKit)
private extension NSImage {
  func heicData(compressionQuality: CGFloat) -> Data? {
    guard let tiffData = self.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let cgImage = bitmapImage.cgImage else {
      return nil
    }
    
    guard let mutableData = CFDataCreateMutable(nil, 0),
          let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil) else {
      return nil
    }
    
    let options: [CFString: Any] = [
      kCGImageDestinationLossyCompressionQuality: compressionQuality
    ]
    
    CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
    guard CGImageDestinationFinalize(destination) else {
      return nil
    }
    
    return mutableData as Data
  }
}
#endif

