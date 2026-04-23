//
//  NSWindow+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(macOS)
import AppKit

public extension NSWindow {
  /// A rectangle describing the window's own coordinate space with the
  /// origin at `(0, 0)`. Convenience for call sites that want a
  /// `UIView.bounds`-shaped value.
  var bounds: NSRect {
    .init(origin: .zero, size: frame.size)
  }
  
  /// Captures the window's own content view into an `NSImage`.
  ///
  /// This uses AppKit's `cacheDisplay(in:to:)` rather than the deprecated
  /// `CGWindowListCreateImage`, so it works without ScreenCaptureKit
  /// entitlements. It also only captures *this* window's content, which
  /// is what most callers want; anything drawn *on top* of the window by
  /// other processes is intentionally not included.
  ///
  /// > Note: Prior to PovioKit 7 this helper composited the on-screen
  /// > region behind the window via `CGWindowListCreateImage`. The
  /// > current implementation is strictly window-local and does not
  /// > require screen-recording entitlements.
  func takeScreenshot() -> NSImage? {
    guard let contentView else { return nil }
    let bounds = contentView.bounds
    guard let bitmap = contentView.bitmapImageRepForCachingDisplay(in: bounds) else {
      return nil
    }
    contentView.cacheDisplay(in: bounds, to: bitmap)
    let image = NSImage(size: bounds.size)
    image.addRepresentation(bitmap)
    return image
  }
}
#endif
