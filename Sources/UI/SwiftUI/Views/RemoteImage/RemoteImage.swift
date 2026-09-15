//
//  RemoteImage.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Kingfisher
import SwiftUI

/// A view that asynchronously loads and displays an image from the provided URL.
///
/// Rendered via Kingfisher's `KFImage` to benefit from its memory and disk cache,
/// fade transitions, and image processors.
///
/// The `RemoteImage` can be parameterized with a custom placeholder view, an
/// option for fade animation, a cache key, and a Kingfisher image processor.
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
/// ## Example with a cache key
///
/// By default the image is cached under its URL. That is wrong whenever the URL is
/// signed or otherwise short-lived: the same picture arrives under a different URL on
/// every fetch, so every fetch is a cache miss and already-drawn images blank out and
/// come down again. Pass whatever identifies the image itself — typically the upload's
/// id from your API — and the URL is then only where to fetch a miss from.
///
/// ```swift
/// RemoteImage(url: media.url, cacheKey: media.id)
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
  private let cacheKey: String?
  private let animated: Bool
  private var placeholder: Placeholder?
  private var processor: ImageProcessor?
  private var onSuccess: ((RetrieveImageResult) -> Void)?
  private var onFailure: ((KingfisherError) -> Void)?
  
  /// Creates a view that loads the image at `url`.
  ///
  /// - Parameters:
  ///   - url: Where to fetch the image from. `nil` renders the placeholder.
  ///   - cacheKey: What to cache the image under. Defaults to `nil`, which keys it by
  ///     `url` — pass an explicit key whenever the URL is signed or otherwise unstable,
  ///     so the same image is not re-downloaded under every new URL.
  ///   - animated: Whether a loaded image fades in.
  public init(
    url: URL?,
    cacheKey: String? = nil,
    animated: Bool = false
  ) where Placeholder == EmptyView {
    self.url = url
    self.cacheKey = cacheKey
    self.animated = animated
    self.placeholder = EmptyView()
    self.processor = nil
    self.onSuccess = nil
    self.onFailure = nil
  }
  
  private init(
    url: URL?,
    cacheKey: String? = nil,
    animated: Bool = false,
    placeholder: Placeholder?,
    processor: ImageProcessor? = nil,
    onSuccess: ((RetrieveImageResult) -> Void)? = nil,
    onFailure: ((KingfisherError) -> Void)? = nil
  ) {
    self.url = url
    self.cacheKey = cacheKey
    self.animated = animated
    self.placeholder = placeholder
    self.processor = processor
    self.onSuccess = onSuccess
    self.onFailure = onFailure
  }
  
  public var body: some View {
    if let url {
      configuredImage(KFImage(source: .network(KF.ImageResource(downloadURL: url, cacheKey: cacheKey))))
    } else {
      placeholder
    }
  }

  private func configuredImage(_ image: KFImage) -> some View {
    let processed = processor.map { image.setProcessor($0) } ?? image
    return processed
      .onSuccess(onSuccess)
      .onFailure(onFailure)
      .placeholder { placeholder }
      .fade(duration: animated ? 0.25 : 0)
      .resizable()
      .scaledToFill()
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
      cacheKey: cacheKey,
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
      cacheKey: cacheKey,
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
      cacheKey: cacheKey,
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
      cacheKey: cacheKey,
      animated: animated,
      placeholder: placeholder,
      processor: processor,
      onSuccess: onSuccess,
      onFailure: callback
    )
  }
}
