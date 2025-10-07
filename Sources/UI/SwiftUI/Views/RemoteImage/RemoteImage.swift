//
//  RemoteImage.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Kingfisher
import SwiftUI

/// A view that asynchronously loads and displays an image from the provided URL.
///
/// If Kingfisher is available, it uses `KFImage` for image loading to support caching,
/// otherwise it falls back to SwiftUI's `AsyncImage`.
///
/// The `RemoteImage` can be parameterized with a custom placeholder view and an
/// option for fade animation.
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
@available(iOS 15.0, *)
public struct RemoteImage<Placeholder: View>: View {
  private let url: URL?
  private let animated: Bool
  private var placeholder: Placeholder?
  private var onSuccess: ((RetrieveImageResult) -> Void)?
  private var onFailure: ((KingfisherError) -> Void)?
  
  public init(
    url: URL?,
    animated: Bool = false
  ) where Placeholder == EmptyView {
    self.url = url
    self.animated = animated
    self.placeholder = EmptyView()
    self.onSuccess = nil
    self.onFailure = nil
  }
  
  private init(
    url: URL?,
    animated: Bool = false,
    placeholder: Placeholder?,
    onSuccess: ((RetrieveImageResult) -> Void)? = nil,
    onFailure: ((KingfisherError) -> Void)? = nil
  ) {
    self.url = url
    self.animated = animated
    self.placeholder = placeholder
    self.onSuccess = onSuccess
    self.onFailure = onFailure
  }
  
  public var body: some View {
    if let url {
      KFImage(url)
        .onSuccess(onSuccess)
        .onFailure(onFailure)
        .placeholder { placeholder }
        .fade(duration: animated ? 0.25 : 0)
        .resizable()
        .scaledToFill()
    } else {
      placeholder
    }
  }
}

@available(iOS 15.0, *)
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
      onSuccess: onSuccess,
      onFailure: callback
    )
  }
}
