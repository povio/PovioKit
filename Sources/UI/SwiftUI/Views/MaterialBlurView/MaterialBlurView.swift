//
//  MaterialBlurView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

#if os(macOS)
import AppKit

/// A view that applies a material blur effect in macOS applications.
///
/// `MaterialBlurView` is an NSViewRepresentable that creates an NSVisualEffectView
/// to apply a material blur effect. You can specify the `material` and `blendingMode`
/// to customize the appearance of the blur effect.
///
/// - Parameters:
///   - material: The material to use for the blur effect (e.g., `.hudWindow`).
///   Defaults to `.hudWindow`.
///   - blendingMode: The blending mode to use (e.g., `.behindWindow`).
///   Defaults to `.behindWindow`.
///
/// ## Usage
/// ```swift
/// MaterialBlurView(material: .hudWindow, blendingMode: .withinWindow)
/// ```
public struct MaterialBlurView: NSViewRepresentable {
  var material: NSVisualEffectView.Material = .hudWindow
  var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  
  public init(
    material: NSVisualEffectView.Material,
    blendingMode: NSVisualEffectView.BlendingMode
  ) {
    self.material = material
    self.blendingMode = blendingMode
  }
  
  public func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = material
    view.blendingMode = blendingMode
    view.state = .active
    return view
  }
  
  public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = material
    nsView.blendingMode = blendingMode
  }
}

#Preview {
  MaterialBlurView(material: .hudWindow, blendingMode: .withinWindow)
}

#elseif os(iOS)

/// A view that applies a material blur effect in iOS applications.
///
/// `MaterialBlurView` is a UIViewRepresentable that creates a UIVisualEffectView
/// to apply a blur effect. You can specify the `style` of the blur effect and
/// choose whether the change should be animated.
///
/// - Parameters:
///   - style: The style of the blur effect (e.g., `.light`, `.dark`).
///   - animated: A Boolean value indicating whether to animate the blur effect.
///   Defaults to `false`.
///
/// ## Usage
/// ```swift
/// RoundedRectange()
///   .background(MaterialBlurView(style: .systemUltraThinMaterialLight))
/// ```
public struct MaterialBlurView: UIViewRepresentable {
  private let style: UIBlurEffect.Style
  private let animated: Bool
  
  public init(style: UIBlurEffect.Style, animated: Bool = false) {
    self.style = style
    self.animated = animated
  }
  
  public func makeUIView(context: Context) -> UIVisualEffectView {
    .init()
  }
  
  public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        uiView.effect = UIBlurEffect(style: style)
      }
    } else {
      uiView.effect = UIBlurEffect(style: style)
    }
  }
}
#endif
