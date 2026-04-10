//
//  NSView+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(macOS)
import AppKit

extension NSView {
  /// Renders the current view as an NSImage.
  func renderAsImage() -> NSImage? {
    let rep = bitmapImageRepForCachingDisplay(in: bounds)
    guard let bitmapRep = rep else { return nil }
    cacheDisplay(in: bounds, to: bitmapRep)
    let image = NSImage(size: bounds.size)
    image.addRepresentation(bitmapRep)
    return image
  }
}
#endif
