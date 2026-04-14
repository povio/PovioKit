//
//  RemoteImageProcessorsTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import Kingfisher
import PovioKitSwiftUI

final class RemoteImageProcessorsTests: XCTestCase {
  func testJPEGProcessorClampsQualityAndIdentifier() {
    let processor = JPEGImageProcessor(compressionQuality: 3.5)

    XCTAssertEqual(processor.compressionQuality, 1.0)
    XCTAssertEqual(processor.identifier, "com.povio.JPEGImageProcessor(1.0)")
  }

  func testHEICProcessorClampsQualityAndIdentifier() {
    let processor = HEICImageProcessor(compressionQuality: -1.0)

    XCTAssertEqual(processor.compressionQuality, 0.0)
    XCTAssertEqual(processor.identifier, "com.povio.HEICImageProcessor(0.0)")
  }

  func testJPEGProcessorDecodesImageData() throws {
    let data = try makePNGData()
    let processor = JPEGImageProcessor(compressionQuality: 0.8)

    let output = processor.process(item: .data(data), options: makeOptions())

    XCTAssertNotNil(output)
  }

  func testHEICProcessorDecodesImageData() throws {
    let data = try makePNGData()
    let processor = HEICImageProcessor(compressionQuality: 0.8)

    let output = processor.process(item: .data(data), options: makeOptions())

    XCTAssertNotNil(output)
  }

  func testJPEGProcessorProcessesImageInput() throws {
    let image = try makeImage()
    let processor = JPEGImageProcessor(compressionQuality: 0.7)

    let output = processor.process(item: .image(image), options: makeOptions())

    XCTAssertNotNil(output)
  }

  func testHEICProcessorProcessesImageInput() throws {
    let image = try makeImage()
    let processor = HEICImageProcessor(compressionQuality: 0.7)

    let output = processor.process(item: .image(image), options: makeOptions())

    XCTAssertNotNil(output)
  }
}

private func makeOptions() -> KingfisherParsedOptionsInfo {
  KingfisherParsedOptionsInfo(KingfisherOptionsInfo([]))
}

#if canImport(UIKit)
import UIKit

private func makeImage() throws -> UIImage {
  let renderer = UIGraphicsImageRenderer(size: CGSize(width: 32, height: 32))
  let image = renderer.image { context in
    UIColor.systemBlue.setFill()
    context.fill(CGRect(x: 0, y: 0, width: 32, height: 32))
  }
  return image
}

private func makePNGData() throws -> Data {
  let image = try makeImage()
  return try XCTUnwrap(image.pngData())
}
#elseif canImport(AppKit)
import AppKit

private func makeImage() throws -> NSImage {
  let size = NSSize(width: 32, height: 32)
  let image = NSImage(size: size)
  image.lockFocus()
  NSColor.systemBlue.setFill()
  NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
  image.unlockFocus()
  return image
}

private func makePNGData() throws -> Data {
  let image = try makeImage()
  let tiffData = try XCTUnwrap(image.tiffRepresentation)
  let bitmapImage = try XCTUnwrap(NSBitmapImageRep(data: tiffData))
  return try XCTUnwrap(bitmapImage.representation(using: .png, properties: [:]))
}
#endif
