//
//  UIImage+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
// UIKit in Swift 6 does not mark `UIImage` as `Sendable`, even though Apple
// documents the class as immutable and safe to use from any thread. The
// async helpers below spawn `Task`s that capture `self` specifically to
// offload CPU-bound image work, so we opt in to `@preconcurrency` here to
// downgrade those Sendable errors to (already-suppressed) warnings.
@preconcurrency import UIKit
import PovioKitCore

public extension UIImage {
  /// Tints image with the given color.
  ///
  /// This method creates a new image by applying a color overlay to the original image.
  /// The color overlay is blended using the `.sourceIn` blend mode, which means the
  /// resulting image will have the shape of the original image but filled with the specified color.
  ///
  /// - Parameter color: The `UIColor` to use as the tint color.
  /// - Returns: A new `UIImage` instance that is tinted with the specified color.
  ///
  /// - Note: If the tinting operation fails, the original image is returned.
  func tinted(with color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    draw(in: rect, blendMode: .normal, alpha: 1)
    
    context?.setBlendMode(.sourceIn)
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage ?? self
  }
  
  /// Creates new image tinted with the given color and size.
  ///
  /// This method generates a new image of the given size, completely filled with the given color.
  ///
  /// - Parameters:
  ///   - color: The `UIColor` to fill the image with.
  ///   - size: The `CGSize` that defines the dimensions of the new image.
  /// - Returns: A new `UIImage` instance filled with the specified color and size. If the image creation fails, an empty `UIImage` is returned.
  ///
  /// - Note: The resulting image is not resizable and will have the exact dimensions specified by the `size` parameter.
  static func with(color: UIColor, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    let path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
    color.setFill()
    path.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
  }
  
  /// Returns existing image clipped to a circle.
  /// Clips the image to a circle.
  ///
  /// This creates a new image by clipping the original image to a circular shape.
  /// The circular clipping is achieved by applying a corner radius that is half the width of the image.
  ///
  /// - Returns: A new `UIImage` instance that is clipped to a circle. If the clipping operation fails, the original image is returned.
  ///
  /// - Note: The resulting image will have a circular shape inscribed within the original image's bounds.
  /// If the original image is not square, the image will still be clipped to a circle, with the diameter
  /// equal to the shorter side of the original image.
  var clipToCircle: UIImage {
    let layer = CALayer()
    layer.frame = .init(origin: .zero, size: size)
    layer.contents = cgImage
    layer.masksToBounds = true
    layer.cornerRadius = size.width / 2
    
    UIGraphicsBeginImageContext(size)
    guard let context = UIGraphicsGetCurrentContext() else { return self }
    layer.render(in: context)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return roundedImage ?? self
  }
  
  /// Saves the image to the photo library asynchronously.
  ///
  /// This function saves this UIImage to the user's photo library. It performs
  /// the operation asynchronously and throws an error if the save operation fails.
  ///
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   try await image.saveImageToPhotoLibrary()
  ///   print("Image saved successfully.")
  /// } catch {
  ///   print("Failed to save image: \(error)")
  /// }
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  /// - Throws: An error if the save operation fails.
  func saveToPhotoLibrary() async throws {
    try await withCheckedThrowingContinuation { continuation in
      let continuationWrapper = ContinuationWrapper(continuation: continuation)
      UIImageWriteToSavedPhotosAlbum(
        self,
        self,
        #selector(saveCompleted),
        Unmanaged.passRetained(continuationWrapper).toOpaque()
      )
    }
  }
  
  /// Downsizes the image to the specified target size, asynchronously, respecting aspect ratio.
  /// - Parameters:
  ///   - targetSize: The desired size to which the image should be downsized.
  /// - Returns: An optional UIImage that is the result of the downsizing operation.
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let targetSize = CGSize(width: 100, height: 100)
  ///   let resizedImage = await image.downsize(toTargetSize: targetSize)
  ///   imageView.image = resizedImage
  /// } catch {
  ///   print("Failed to downsize image: \(error)")
  /// }
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  func downsize(toTargetSize targetSize: CGSize) async throws -> UIImage {
    guard !targetSize.width.isZero, !targetSize.height.isZero else {
      throw ImageError.invalidSize
    }
    
    return await Task(priority: .high) {
      let widthRatio = targetSize.width / size.width
      let heightRatio = targetSize.height / size.height
      let scaleFactor = min(widthRatio, heightRatio)
      let newSize = CGSize(
        width: floor(size.width * scaleFactor),
        height: floor(size.height * scaleFactor)
      )
      
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let newImage = renderer.image { _ in
        draw(in: CGRect(origin: .zero, size: newSize))
      }
      
      return newImage
    }.value
  }
  
  /// Downsizes the image by the specified percentage asynchronously.
  /// - Parameters:
  ///   - percentage: The percentage by which the image should be downsized. Must be greater than 0 and less than or equal to 100.
  /// - Returns: A UIImage that is the result of the downsizing operation.
  ///
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let percentage: CGFloat = 50.0
  ///   let resizedImage = try await image.downsize(byPercentage: percentage)
  ///   imageView.image = resizedImage
  /// } catch {
  ///   print("Failed to downsize image: \(error)")
  /// }
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  /// - Throws: `ImageError.invalidPercentage` if the percentage is not within the valid range.
  func downsize(byPercentage percentage: CGFloat) async throws -> UIImage {
    guard percentage > 0 && percentage <= 100 else {
      throw ImageError.invalidPercentage
    }
    
    return await Task(priority: .high) {
      let scaleFactor = percentage / 100.0
      let newSize = CGSize(
        width: size.width * scaleFactor,
        height: size.height * scaleFactor
      )
      
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let newImage = renderer.image { _ in
        draw(in: CGRect(origin: .zero, size: newSize))
      }
      
      return newImage
    }.value
  }
  
  /// Compresses the image to the specified format.
  ///
  /// This function compresses UIImage to the specified format (JPEG or PNG).
  /// It returns the compressed image data.
  /// If the compression operation fails, the function throws an error.
  ///
  /// - Parameters:
  ///   - format: The desired image format (JPEG or PNG).
  /// - Returns: The compressed image data as `Data`.
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let compressedData = try await image.compress(to: .jpeg(compressionRatio: 0.8))
  /// } catch {
  ///   print("Failed to compress image: \(error)")
  /// }
  /// ```
  /// - Throws: `ImageError.compression` if the compression operation fails.
  func compress(toFormat format: ImageFormat) async throws -> Data {
    try await Task(priority: .high) {
      let compressedImage: Data?
      switch format {
      case .jpeg(let compressionRatio):
        compressedImage = jpegData(compressionQuality: compressionRatio)
      case .png:
        compressedImage = pngData()
      }
      
      guard let compressedImage else { throw ImageError.compression }
      
      Logger.debug("Image compressed to \(Double(compressedImage.count) / 1024.0) KB.")
      return compressedImage
    }.value
  }
  
  /// Compresses the image to given `maxKbSize`.
  ///
  /// This function compresses UIImage to the specified size in KB.
  /// It returns the compressed image data.
  /// If the compression operation fails, the function throws an error.
  ///
  /// - Parameters:
  ///   - maxSizeInKb: The desired max size in KB.
  /// - Returns: The compressed image data as `Data`.
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let compressedData = try await image.compress(toMaxKbSize: 500)
  /// } catch {
  ///   print("Failed to compress image: \(error)")
  /// }
  /// ```
  /// - Throws: `ImageError.compression` if the compression operation fails.
  func compress(toMaxKbSize maxKbSize: CGFloat) async throws -> Data {
    guard maxKbSize > 0 else { throw ImageError.invalidSize }
    
    return try await Task(priority: .high) {
      let maxBytes = Int(maxKbSize * 1024)
      let compressionStep: CGFloat = 0.05
      var compression: CGFloat = 1.0
      var compressedData: Data?
      
      // try to compress the image by reducing the quality until reached desired `maxSizeInKb`
      while compression > 0.0 {
        let data = try await compress(toFormat: .jpeg(compressionRatio: compression))
        if data.count <= maxBytes {
          compressedData = data
          break
        } else {
          compression -= compressionStep
        }
      }
      
      guard let compressedData else { throw ImageError.compression }
      return compressedData
    }.value
  }
  
  enum ImageFormat: Sendable {
    case jpeg(compressionRatio: CGFloat)
    case png
  }
}

// MARK: - Private Methods
private extension UIImage {
  class ContinuationWrapper {
    let continuation: CheckedContinuation<Void, Error>
    
    init(continuation: CheckedContinuation<Void, Error>) {
      self.continuation = continuation
    }
  }
  
  @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    let continuationWrapper = Unmanaged<ContinuationWrapper>.fromOpaque(contextInfo).takeRetainedValue()
    
    if let error = error {
      continuationWrapper.continuation.resume(throwing: error)
    } else {
      continuationWrapper.continuation.resume()
    }
  }
  
  enum ImageError: LocalizedError {
    case invalidPercentage
    case compression
    case invalidSize
  }
}

#endif
