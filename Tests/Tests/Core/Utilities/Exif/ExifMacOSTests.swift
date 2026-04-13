//
//  ExifMacOSTests.swift
//  PovioKit_Tests
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(macOS)
import XCTest
import AppKit
import ImageIO
import PovioKitUtilities

final class ExifMacOSTests: XCTestCase {
  func testReadReturnsImagePropertiesForValidImageData() throws {
    let imageData = try makeJPEGData()
    let exif = Exif(source: .data(imageData))
    
    let result = try exif.read()
    
    XCTAssertFalse(result.isEmpty)
    XCTAssertNotNil(result[kCGImagePropertyPixelWidth as String])
  }
  
  func testUpdateWritesExifMetadata() throws {
    let imageData = try makeJPEGData()
    let manager = Exif(source: .data(imageData))
    let updated = try manager.update([kCGImagePropertyExifUserComment: "Povio test"])
    
    let readback = try Exif(source: .data(updated)).read()
    let exifData = try XCTUnwrap(readback["{Exif}"] as? [String: Any])
    XCTAssertEqual(exifData["UserComment"] as? String, "Povio test")
  }
  
  func testReadThrowsForInvalidData() {
    let exif = Exif(source: .data(Data([0x00, 0x01, 0x02])))
    
    XCTAssertThrowsError(try exif.read())
  }
  
  private func makeJPEGData() throws -> Data {
    let size = NSSize(width: 100, height: 100)
    let image = NSImage(size: size)
    image.lockFocus()
    NSColor.systemBlue.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
    image.unlockFocus()
    
    let tiffData = try XCTUnwrap(image.tiffRepresentation)
    let bitmapImage = try XCTUnwrap(NSBitmapImageRep(data: tiffData))
    return try XCTUnwrap(bitmapImage.representation(using: .jpeg, properties: [:]))
  }
}
#endif
