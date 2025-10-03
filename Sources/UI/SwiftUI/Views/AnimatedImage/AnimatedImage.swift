//
//  SwiftUIView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 25/02/2025.
//

#if canImport(Kingfisher)
import Kingfisher
import SwiftUI

/// A view that displays an animated image (a.k.a GIF) either from a local file or a remote URL.
///
/// It uses `Kingfisher` for handling the image loading from both sources.
/// This implementation provides access to advanced animation customization options.
@available(iOS 15.0, *)
public struct AnimatedImage: View {
  private let source: Source
  private let autoplay: Bool
  private let repeatCount: AnimatedImageView.RepeatCount
  private let options: KingfisherOptionsInfo?
  private let onAnimationStart: (() -> Void)?
  private let onAnimationEnd: (() -> Void)?
  
  public init(
    source: Source,
    autoplay: Bool = true,
    repeatCount: AnimatedImageView.RepeatCount = .infinite,
    options: KingfisherOptionsInfo? = nil,
    onAnimationStart: (() -> Void)? = nil,
    onAnimationEnd: (() -> Void)? = nil
  ) {
    self.source = source
    self.autoplay = autoplay
    self.repeatCount = repeatCount
    self.options = options
    self.onAnimationStart = onAnimationStart
    self.onAnimationEnd = onAnimationEnd
  }
  
  public var body: some View {
    AnimatedImageViewRepresentable(
      source: source,
      autoplay: autoplay,
      repeatCount: repeatCount,
      options: options,
      onAnimationStart: onAnimationStart,
      onAnimationEnd: onAnimationEnd
    )
  }
}

@available(iOS 15.0, *)
private struct AnimatedImageViewRepresentable: UIViewRepresentable {
  let source: AnimatedImage.Source
  let autoplay: Bool
  let repeatCount: AnimatedImageView.RepeatCount
  let options: KingfisherOptionsInfo?
  let onAnimationStart: (() -> Void)?
  let onAnimationEnd: (() -> Void)?
  
  func makeUIView(context: Context) -> AnimatedImageView {
    let imageView = AnimatedImageView()
    imageView.autoPlayAnimatedImage = autoplay
    imageView.repeatCount = repeatCount
    imageView.delegate = context.coordinator
    return imageView
  }
  
  func updateUIView(_ imageView: AnimatedImageView, context: Context) {
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
    Coordinator(onAnimationStart: onAnimationStart, onAnimationEnd: onAnimationEnd)
  }
  
  class Coordinator: NSObject, AnimatedImageViewDelegate {
    let onAnimationStart: (() -> Void)?
    let onAnimationEnd: (() -> Void)?
    
    init(onAnimationStart: (() -> Void)?, onAnimationEnd: (() -> Void)?) {
      self.onAnimationStart = onAnimationStart
      self.onAnimationEnd = onAnimationEnd
    }
    
    func animatedImageView(_ imageView: AnimatedImageView, didStartAnimating image: KFCrossPlatformImage) {
      onAnimationStart?()
    }
    
    func animatedImageView(_ imageView: AnimatedImageView, didStopAnimating image: KFCrossPlatformImage) {
      onAnimationEnd?()
    }
  }
}

@available(iOS 15.0, *)
public extension AnimatedImage {
  /// Enum representing the source of the animated image.
  enum Source {
    case local(fileName: String)
    case remote(url: URL?)
  }
}
#endif
