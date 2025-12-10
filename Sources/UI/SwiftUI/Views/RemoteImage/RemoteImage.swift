//
//  RemoteImage.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Kingfisher
import SwiftUI

/// A view that asynchronously loads and displays an image from the provided URL.
///
/// If Kingfisher is available, it uses `KFImage` for image loading to support caching,
/// otherwise it falls back to SwiftUI's `AsyncImage`.
///
/// The `RemoteImage` can be parameterized with a custom placeholder view, an
/// option for fade animation, and a Kingfisher image processor.
///
/// ## Example with placeholder
/// ```swift
/// RemoteImage(url: URL(string: "https://example.com/image.jpg"), animated: true)
///   .placeholder {
///     Text("Loading...")
///       .foregroundColor(.gray)
///   }
///   .onSuccess { result in
///     print("Image loaded successfully")
///   }
///   .onFailure { error in
///     print("Failed to load image: \(error)")
///   }
/// ```
///
/// ## Example with image processor
/// ```swift
/// let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))
/// RemoteImage(url: URL(string: "https://example.com/image.jpg"))
///   .processor(processor)
/// ```
///
/// ## Example with downsampling and JPEG compression
/// ```swift
/// let processor = DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
///     |> JPEGImageProcessor(compressionQuality: 0.8)
/// RemoteImage(url: URL(string: "https://example.com/image.jpg"))
///   .processor(processor)
/// ```
///
/// ## Example with downsampling and HEIC compression (best compression)
/// ```swift
/// let processor = DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
///     |> HEICImageProcessor(compressionQuality: 0.8)
/// RemoteImage(url: URL(string: "https://example.com/image.jpg"))
///   .processor(processor)
/// ```
public struct RemoteImage<Placeholder: View>: View {
  private let url: URL?
  private let animated: Bool
  private var placeholder: Placeholder?
  private var processor: ImageProcessor?
  private var onSuccess: ((RetrieveImageResult) -> Void)?
  private var onFailure: ((KingfisherError) -> Void)?
  
  public init(
    url: URL?,
    animated: Bool = false
  ) where Placeholder == EmptyView {
    self.url = url
    self.animated = animated
    self.placeholder = EmptyView()
    self.processor = nil
    self.onSuccess = nil
    self.onFailure = nil
  }
  
  private init(
    url: URL?,
    animated: Bool = false,
    placeholder: Placeholder?,
    processor: ImageProcessor? = nil,
    onSuccess: ((RetrieveImageResult) -> Void)? = nil,
    onFailure: ((KingfisherError) -> Void)? = nil
  ) {
    self.url = url
    self.animated = animated
    self.placeholder = placeholder
    self.processor = processor
    self.onSuccess = onSuccess
    self.onFailure = onFailure
  }
  
  public var body: some View {
    if let url {
      let baseImage = KFImage(url)
      if let processor {
        baseImage
          .setProcessor(processor)
          .onSuccess(onSuccess)
          .onFailure(onFailure)
          .placeholder { placeholder }
          .fade(duration: animated ? 0.25 : 0)
          .resizable()
          .scaledToFill()
      } else {
        baseImage
          .onSuccess(onSuccess)
          .onFailure(onFailure)
          .placeholder { placeholder }
          .fade(duration: animated ? 0.25 : 0)
          .resizable()
          .scaledToFill()
      }
    } else {
      placeholder
    }
  }
}

public extension RemoteImage {
  /// Sets a custom placeholder view for the `RemoteImage`.
  ///
  /// - Parameter placeholder: A view builder that creates a placeholder view displayed
  ///   while the image is loading or if the URL is `nil`.
  /// - Returns: A new `RemoteImage` instance with the specified placeholder.
  func placeholder<NewPlaceholder: View>(
    @ViewBuilder placeholder: () -> NewPlaceholder
  ) -> RemoteImage<NewPlaceholder> {
    RemoteImage<NewPlaceholder>(
      url: url,
      animated: animated,
      placeholder: placeholder(),
      processor: processor,
      onSuccess: onSuccess,
      onFailure: onFailure
    )
  }
  
  /// Sets a Kingfisher image processor for the `RemoteImage`.
  ///
  /// - Parameter processor: An `ImageProcessor` instance to process the image before display.
  ///   Common processors include `DownsamplingImageProcessor`, `RoundCornerImageProcessor`,
  ///   `JPEGImageProcessor`, `HEICImageProcessor`, etc. Processors can be chained using the `|>` operator.
  /// - Returns: A new `RemoteImage` instance with the specified processor.
  func processor(_ processor: ImageProcessor?) -> RemoteImage {
    RemoteImage(
      url: url,
      animated: animated,
      placeholder: placeholder,
      processor: processor,
      onSuccess: onSuccess,
      onFailure: onFailure
    )
  }
  
  /// Sets a success callback for the `RemoteImage`.
  ///
  /// - Parameter callback: A closure that gets called when the image is successfully loaded.
  /// - Returns: A new `RemoteImage` instance with the specified success callback.
  func onSuccess(_ callback: @escaping (RetrieveImageResult) -> Void) -> RemoteImage {
    RemoteImage(
      url: url,
      animated: animated,
      placeholder: placeholder,
      processor: processor,
      onSuccess: callback,
      onFailure: onFailure
    )
  }
  
  /// Sets a failure callback for the `RemoteImage`.
  ///
  /// - Parameter callback: A closure that gets called when the image fails to load.
  /// - Returns: A new `RemoteImage` instance with the specified failure callback.
  func onFailure(_ callback: @escaping (KingfisherError) -> Void) -> RemoteImage {
    RemoteImage(
      url: url,
      animated: animated,
      placeholder: placeholder,
      processor: processor,
      onSuccess: onSuccess,
      onFailure: callback
    )
  }
}
