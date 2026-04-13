//
//  ExifImageSourceTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class ExifImageSourceTests: XCTestCase {
  
  // MARK: - URL Case
  
  func testCreateWithUrl() {
    let url = URL(fileURLWithPath: "/path/to/image.jpg")
    let source = ExifImageSource.url(url)
    
    if case .url(let extractedUrl) = source {
      XCTAssertEqual(extractedUrl, url, "Should store the URL")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  func testCreateWithFileUrl() {
    let url = URL(fileURLWithPath: "/tmp/test.png")
    let source = ExifImageSource.url(url)
    
    if case .url(let extractedUrl) = source {
      XCTAssertEqual(extractedUrl.path, "/tmp/test.png", "Should store file URL path")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  func testCreateWithHttpUrl() {
    let url = URL(string: "https://example.com/image.jpg")!
    let source = ExifImageSource.url(url)
    
    if case .url(let extractedUrl) = source {
      XCTAssertEqual(extractedUrl.absoluteString, "https://example.com/image.jpg", "Should store HTTP URL")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  // MARK: - Data Case
  
  func testCreateWithData() {
    let data = Data([0x01, 0x02, 0x03, 0x04])
    let source = ExifImageSource.data(data)
    
    if case .data(let extractedData) = source {
      XCTAssertEqual(extractedData, data, "Should store the data")
    } else {
      XCTFail("Should be data case")
    }
  }
  
  func testCreateWithEmptyData() {
    let data = Data()
    let source = ExifImageSource.data(data)
    
    if case .data(let extractedData) = source {
      XCTAssertEqual(extractedData.count, 0, "Should store empty data")
    } else {
      XCTFail("Should be data case")
    }
  }
  
  func testCreateWithLargeData() {
    let data = Data(repeating: 0xFF, count: 1_000_000)
    let source = ExifImageSource.data(data)
    
    if case .data(let extractedData) = source {
      XCTAssertEqual(extractedData.count, 1_000_000, "Should store large data")
    } else {
      XCTFail("Should be data case")
    }
  }
  
  // MARK: - Pattern Matching
  
  func testPatternMatchingUrl() {
    let url = URL(fileURLWithPath: "/path/to/image.jpg")
    let source = ExifImageSource.url(url)
    
    switch source {
    case .url(let extractedUrl):
      XCTAssertEqual(extractedUrl, url, "Pattern matching should extract URL")
    case .data:
      XCTFail("Should match URL case")
    }
  }
  
  func testPatternMatchingData() {
    let data = Data([0x01, 0x02, 0x03])
    let source = ExifImageSource.data(data)
    
    switch source {
    case .url:
      XCTFail("Should match data case")
    case .data(let extractedData):
      XCTAssertEqual(extractedData, data, "Pattern matching should extract data")
    }
  }
  
  func testPatternMatchingWithoutAssociatedValue() {
    let urlSource = ExifImageSource.url(URL(fileURLWithPath: "/test.jpg"))
    let dataSource = ExifImageSource.data(Data())
    
    if case .url = urlSource {
      XCTAssertTrue(true, "Should match URL case without extracting value")
    } else {
      XCTFail("Should match URL case")
    }
    
    if case .data = dataSource {
      XCTAssertTrue(true, "Should match data case without extracting value")
    } else {
      XCTFail("Should match data case")
    }
  }
  
  // MARK: - Associated Value Comparison
  
  func testExtractingUrlFromUrlCase() {
    let expectedUrl = URL(fileURLWithPath: "/path/to/image.jpg")
    let source = ExifImageSource.url(expectedUrl)
    
    if case .url(let extractedUrl) = source {
      XCTAssertEqual(extractedUrl, expectedUrl, "Should extract same URL")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  func testExtractingDataFromDataCase() {
    let expectedData = Data([0x01, 0x02, 0x03])
    let source = ExifImageSource.data(expectedData)
    
    if case .data(let extractedData) = source {
      XCTAssertEqual(extractedData, expectedData, "Should extract same data")
    } else {
      XCTFail("Should be data case")
    }
  }
  
  func testCannotExtractDataFromUrlCase() {
    let url = URL(fileURLWithPath: "/test.jpg")
    let source = ExifImageSource.url(url)
    
    if case .data = source {
      XCTFail("Should not match data case")
    } else {
      XCTAssertTrue(true, "Correctly does not match data case")
    }
  }
  
  func testCannotExtractUrlFromDataCase() {
    let data = Data([0x01, 0x02])
    let source = ExifImageSource.data(data)
    
    if case .url = source {
      XCTFail("Should not match URL case")
    } else {
      XCTAssertTrue(true, "Correctly does not match URL case")
    }
  }
  
  // MARK: - Real-World Scenarios
  
  func testPngImageFromUrl() {
    let url = URL(fileURLWithPath: "/path/to/image.png")
    let source = ExifImageSource.url(url)
    
    if case .url(let extractedUrl) = source {
      XCTAssertTrue(extractedUrl.path.hasSuffix(".png"), "Should handle PNG URL")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  func testJpgImageFromUrl() {
    let url = URL(fileURLWithPath: "/path/to/image.jpg")
    let source = ExifImageSource.url(url)
    
    if case .url(let extractedUrl) = source {
      XCTAssertTrue(extractedUrl.path.hasSuffix(".jpg"), "Should handle JPG URL")
    } else {
      XCTFail("Should be URL case")
    }
  }
  
  func testImageDataFromMemory() {
    // Simulate image data in memory
    let imageData = Data([0xFF, 0xD8, 0xFF, 0xE0]) // JPEG header
    let source = ExifImageSource.data(imageData)
    
    if case .data(let extractedData) = source {
      XCTAssertEqual(extractedData.prefix(4), Data([0xFF, 0xD8, 0xFF, 0xE0]), "Should preserve image header")
    } else {
      XCTFail("Should be data case")
    }
  }
  
  func testSwitchingBetweenSources() {
    let url = URL(fileURLWithPath: "/temp/image.jpg")
    let data = Data([0x01, 0x02, 0x03])
    
    var source: ExifImageSource = .url(url)
    
    if case .url = source {
      XCTAssertTrue(true, "Initially URL source")
    }
    
    source = .data(data)
    
    if case .data = source {
      XCTAssertTrue(true, "Changed to data source")
    } else {
      XCTFail("Should be data source after change")
    }
  }
  
  func testArrayOfMixedSources() {
    let sources: [ExifImageSource] = [
      .url(URL(fileURLWithPath: "/image1.jpg")),
      .data(Data([0x01, 0x02])),
      .url(URL(fileURLWithPath: "/image2.png")),
      .data(Data([0x03, 0x04]))
    ]
    
    XCTAssertEqual(sources.count, 4, "Should store mixed sources in array")
    
    let urlCount = sources.filter { if case .url = $0 { return true }; return false }.count
    let dataCount = sources.filter { if case .data = $0 { return true }; return false }.count
    
    XCTAssertEqual(urlCount, 2, "Should have 2 URL sources")
    XCTAssertEqual(dataCount, 2, "Should have 2 data sources")
  }
}

