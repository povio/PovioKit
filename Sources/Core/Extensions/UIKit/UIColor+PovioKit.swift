//
//  UIColor+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIColor {
  /// Initializes a `UIColor` using integer values for red, green, and blue components.
  ///
  /// This convenience initializer allows you to create a `UIColor` using integer values for the RGB components, where each component is expected to be in the range 0 to 255. It also allows an optional alpha component (opacity), with a default value of 1 (fully opaque).
  ///
  /// - Parameters:
  ///   - red: The red component of the color, ranging from 0 to 255.
  ///   - green: The green component of the color, ranging from 0 to 255.
  ///   - blue: The blue component of the color, ranging from 0 to 255.
  ///   - alpha: The alpha (opacity) of the color, ranging from 0 (fully transparent) to 1 (fully opaque). Defaults to 1.
  convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
    self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
  }
}

#endif
