//
//  BlurBackgroundModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

#if os(macOS)
struct MaterialBlurBackgroundModifier: ViewModifier {
  var material: NSVisualEffectView.Material = .hudWindow
  var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  
  func body(content: Content) -> some View {
    content.background(MaterialBlurView(material: material, blendingMode: blendingMode))
  }
}

public extension View {
  func blurBackground(
    material: NSVisualEffectView.Material = .hudWindow,
    blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
  ) -> some View {
    modifier(MaterialBlurBackgroundModifier(material: material, blendingMode: blendingMode))
  }
}

#elseif os(iOS)
struct MaterialBlurBackgroundModifier: ViewModifier {
  var style: UIBlurEffect.Style
  var animated: Bool = false
  
  func body(content: Content) -> some View {
    content.background(MaterialBlurView(style: style, animated: animated))
  }
}

public extension View {
  func blurBackground(
    style: UIBlurEffect.Style,
    animated: Bool = false
  ) -> some View {
    modifier(MaterialBlurBackgroundModifier(style: style, animated: animated))
  }
}
#endif
