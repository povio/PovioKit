//
//  View+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

public extension View {
  /// Returns square frame for given `size`.
  func frame(size: CGFloat? = nil, alignment: Alignment = .center) -> some View {
    frame(width: size, height: size, alignment: alignment)
  }
  
  /// Returns square frame for given CGSize.
  func frame(size: CGSize, alignment: Alignment = .center) -> some View {
    frame(width: size.width, height: size.height, alignment: alignment)
  }
  
  /// Hides view using opacity.
  func hidden(_ hidden: Bool) -> some View {
    opacity(hidden ? 0 : 1)
  }
  
  /// Disables animation on view.
  func noAnimation() -> some View {
    animation(nil, value: UUID())
  }
}
