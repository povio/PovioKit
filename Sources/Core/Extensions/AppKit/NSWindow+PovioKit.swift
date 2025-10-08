//
//  NSWindow+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 24/09/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(macOS)
import AppKit

extension NSWindow {
  var bounds: NSRect {
    .init(origin: .zero, size: frame.size)
  }
  
  /// Takes a screenshot of the window and returns it as an NSImage.
  func takeScreenshot() -> NSImage? {
    // not sure why we always target first screen insted of the current one
    guard let screen = NSScreen.screens.first else { return nil }
    let screenHeight = screen.frame.height
    let windowRect = frame
    let screenshotRect = NSRect(
      x: windowRect.minX,
      y: screenHeight - windowRect.minY - windowRect.height,
      width: windowRect.width,
      height: windowRect.height
    )
    
    // make sure the window keeps its aspect ratio when resizing
    aspectRatio = frame.size
    alphaValue = 0.0
    backgroundColor = .clear
    
    let screenshot = CGWindowListCreateImage(
      screenshotRect,
      .optionAll,
      kCGNullWindowID,
      .bestResolution
    )
    
    return screenshot.map { NSImage(cgImage: $0, size: .zero) }
  }
}
#endif
