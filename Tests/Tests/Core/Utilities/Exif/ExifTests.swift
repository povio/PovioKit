//
//  ExifTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 05/05/2023.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitCore
import PovioKitUtilities

final class ExifTests: XCTestCase {
  let image = UIImage.with(color: .blue, size: .init(width: 100, height: 100))
  
  func test_imageExifRead() {
    guard let imageData = image.jpegData(compressionQuality: 1) else {
      XCTFail("Failed to generate image data!")
      return
    }
    
    do {
      let manager = Exif(source: .data(imageData))
      let data = try manager.read()
      XCTAssertFalse(data.isEmpty)
      XCTAssertTrue(data.contains(where: { $0.key == "{Exif}" }))
    } catch {
      XCTFail("Failed to read exif data! \(error.localizedDescription)")
    }
  }
  
  func test_imageExifWrite() {
    guard let imageData = image.jpegData(compressionQuality: 1) else {
      XCTFail("Failed to generate image data!")
      return
    }
    
    do {
      let writeManager = Exif(source: .data(imageData))
      let updateValue = "Test comment!"
      let updateData = [kCGImagePropertyExifUserComment: updateValue]
      let updatedData = try writeManager.update(updateData)
      
      let readManager = Exif(source: .data(updatedData))
      let newData = try readManager.read()
      
      XCTAssertFalse(newData.isEmpty)
      guard let exifData = newData["{Exif}"] as? [String: Any] else {
        XCTFail("Missing exif container!")
        return
      }
      guard let value = exifData["UserComment"] as? String else {
        XCTFail("Missing UserComment container!")
        return
      }
      XCTAssertEqual(value, updateValue)
    } catch {
      XCTFail("Failed to write and/or read exif data! \(error.localizedDescription)")
    }
  }
}
#endif
