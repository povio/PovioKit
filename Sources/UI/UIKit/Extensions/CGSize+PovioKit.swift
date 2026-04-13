//
//  CGSize+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension CGSize {
  /// Initializes a `CGSize` with equal width and height.
  ///
  /// This initializer creates a `CGSize` instance where both the width and height are set to the provided value. It can be useful for creating square sizes.
  ///
  /// - Parameter size: The value to set for both the width and height of the `CGSize`.
  /// - Returns: A `CGSize` instance with both dimensions equal to the specified `size`.
  ///
  /// ## Example
  /// ```swift
  /// let squareSize = CGSize(size: 50)
  /// Logger.debug(squareSize) // (50.0, 50.0)
  /// ```
  init(size: CGFloat) {
    self.init(width: size, height: size)
  }
}

#endif
