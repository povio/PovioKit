//
//  SwiftUIView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import Kingfisher
import SwiftUI

/// A view that displays an animated image (a.k.a GIF) either from a local file or a remote URL.
///
/// It uses `Kingfisher` for handling the image loading from both sources.
/// This implementation provides access to advanced animation customization options.
public struct AnimatedImage: View {
  private let source: Source
  private let autoplay: Bool
  private let repeatCount: AnimatedImageView.RepeatCount
  private let options: KingfisherOptionsInfo?
  private var onStart: (() -> Void)?
  private var onEnd: (() -> Void)?
  
  public init(
    source: Source,
    autoplay: Bool = true,
    repeatCount: AnimatedImageView.RepeatCount = .infinite,
    options: KingfisherOptionsInfo? = nil
  ) {
    self.source = source
    self.autoplay = autoplay
    self.repeatCount = repeatCount
    self.options = options
    self.onStart = nil
    self.onEnd = nil
  }

  private init(
    source: Source,
    autoplay: Bool = true,
    repeatCount: AnimatedImageView.RepeatCount = .infinite,
    options: KingfisherOptionsInfo? = nil,
    onStart: (() -> Void)? = nil,
    onEnd: (() -> Void)? = nil
  ) {
    self.source = source
    self.autoplay = autoplay
    self.repeatCount = repeatCount
    self.options = options
    self.onStart = onStart
    self.onEnd = onEnd
  }
  
  public var body: some View {
    AnimatedImageViewRepresentable(
      source: source,
      autoplay: autoplay,
      repeatCount: repeatCount,
      options: options,
      onAnimationStart: onStart,
      onAnimationEnd: onEnd
    )
  }
}

private class CustomAnimatedImageView: AnimatedImageView {
  var onAnimationStart: (() -> Void)?

  override func startAnimating() {
    super.startAnimating()
    // Call the start callback when animation actually begins
    onAnimationStart?()
  }
}

private struct AnimatedImageViewRepresentable: UIViewRepresentable {
  let source: AnimatedImage.Source
  let autoplay: Bool
  let repeatCount: AnimatedImageView.RepeatCount
  let options: KingfisherOptionsInfo?
  let onAnimationStart: (() -> Void)?
  let onAnimationEnd: (() -> Void)?

  func makeUIView(context: Context) -> CustomAnimatedImageView {
    let imageView = CustomAnimatedImageView()
    imageView.autoPlayAnimatedImage = autoplay
    imageView.repeatCount = repeatCount
    imageView.delegate = context.coordinator
    imageView.onAnimationStart = onAnimationStart
    return imageView
  }
  
  func updateUIView(_ imageView: CustomAnimatedImageView, context: Context) {
    // Update the image source
    switch source {
    case .local(let fileName):
      if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "gif") {
        imageView.kf.setImage(
          with: .provider(LocalFileImageDataProvider(fileURL: fileUrl)),
          options: options
        )
      }
    case .remote(let url):
      if let url = url {
        imageView.kf.setImage(
          with: url,
          options: options
        )
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(onAnimationEnd: onAnimationEnd)
  }
  
  class Coordinator: NSObject, AnimatedImageViewDelegate {
    let onEnd: (() -> Void)?

    init(onAnimationEnd: (() -> Void)?) {
      self.onEnd = onAnimationEnd
    }

    func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView) {
      onEnd?()
    }
  }
}

public extension AnimatedImage {
  /// Enum representing the source of the animated image.
  enum Source {
    case local(fileName: String)
    case remote(url: URL?)
  }

  /// Sets a start callback for the `AnimatedImage`.
  ///
  /// - Parameter callback: A closure that gets called when the animation starts.
  /// - Returns: A new `AnimatedImage` instance with the specified start callback.
  func onStart(_ callback: @escaping () -> Void) -> AnimatedImage {
    AnimatedImage(
      source: source,
      autoplay: autoplay,
      repeatCount: repeatCount,
      options: options,
      onStart: callback,
      onEnd: onEnd
    )
  }

  /// Sets an end callback for the `AnimatedImage`.
  ///
  /// - Parameter callback: A closure that gets called when the animation ends.
  /// - Returns: A new `AnimatedImage` instance with the specified end callback.
  func onEnd(_ callback: @escaping () -> Void) -> AnimatedImage {
    AnimatedImage(
      source: source,
      autoplay: autoplay,
      repeatCount: repeatCount,
      options: options,
      onStart: onStart,
      onEnd: callback
    )
  }
}
#endif
