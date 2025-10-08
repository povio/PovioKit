//
//  CGSizeTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import UIKit
import PovioKitCore

final class CGSizeTests: XCTestCase {
  
  // MARK: - Square Size Initializer
  
  func testSquareSizeInitializer() {
    let size = CGSize(size: 50)
    
    XCTAssertEqual(size.width, 50, "Width should equal the provided size")
    XCTAssertEqual(size.height, 50, "Height should equal the provided size")
  }
  
  func testSquareSizeWithZero() {
    let size = CGSize(size: 0)
    
    XCTAssertEqual(size.width, 0, "Width should be zero")
    XCTAssertEqual(size.height, 0, "Height should be zero")
    XCTAssertEqual(size, .zero, "Should equal CGSize.zero")
  }
  
  func testSquareSizeWithNegativeValue() {
    let size = CGSize(size: -10)
    
    XCTAssertEqual(size.width, -10, "Width should be negative")
    XCTAssertEqual(size.height, -10, "Height should be negative")
  }
  
  func testSquareSizeWithLargeValue() {
    let largeValue: CGFloat = 10000
    let size = CGSize(size: largeValue)
    
    XCTAssertEqual(size.width, largeValue, "Width should handle large values")
    XCTAssertEqual(size.height, largeValue, "Height should handle large values")
  }
  
  func testSquareSizeWithFractionalValue() {
    let size = CGSize(size: 42.5)
    
    XCTAssertEqual(size.width, 42.5, accuracy: 0.001, "Width should handle fractional values")
    XCTAssertEqual(size.height, 42.5, accuracy: 0.001, "Height should handle fractional values")
  }
  
  func testSquareSizeWithVerySmallValue() {
    let size = CGSize(size: 0.001)
    
    XCTAssertEqual(size.width, 0.001, accuracy: 0.0001, "Width should handle very small values")
    XCTAssertEqual(size.height, 0.001, accuracy: 0.0001, "Height should handle very small values")
  }
  
  // MARK: - Comparison with Standard Initializer
  
  func testSquareSizeEquivalentToStandardInitializer() {
    let value: CGFloat = 100
    let squareSize = CGSize(size: value)
    let standardSize = CGSize(width: value, height: value)
    
    XCTAssertEqual(squareSize, standardSize, "Square size should equal standard initializer with same width/height")
  }
  
  // MARK: - Properties
  
  func testSquareSizeIsSquare() {
    let size = CGSize(size: 75)
    
    XCTAssertEqual(size.width, size.height, "Width and height should be equal")
  }
  
  func testSquareSizeArea() {
    let size = CGSize(size: 10)
    let area = size.width * size.height
    
    XCTAssertEqual(area, 100, "Area of 10x10 square should be 100")
  }
  
  // MARK: - Use Cases
  
  func testCommonSquareSizes() {
    let commonSizes: [CGFloat] = [16, 24, 32, 44, 64, 100, 200]
    
    for value in commonSizes {
      let size = CGSize(size: value)
      XCTAssertEqual(size.width, value, "Width should match for common size \(value)")
      XCTAssertEqual(size.height, value, "Height should match for common size \(value)")
    }
  }
  
  func testIconSizes() {
    let iconSize = CGSize(size: 44) // Common iOS touch target
    
    XCTAssertEqual(iconSize.width, 44, "Icon width should be 44")
    XCTAssertEqual(iconSize.height, 44, "Icon height should be 44")
  }
  
  func testThumbnailSize() {
    let thumbnailSize = CGSize(size: 100)
    
    XCTAssertEqual(thumbnailSize.width, 100, "Thumbnail width should be 100")
    XCTAssertEqual(thumbnailSize.height, 100, "Thumbnail height should be 100")
  }
  
  // MARK: - Edge Cases
  
  func testSquareSizeWithInfinity() {
    let size = CGSize(size: .infinity)
    
    XCTAssertTrue(size.width.isInfinite, "Width should be infinite")
    XCTAssertTrue(size.height.isInfinite, "Height should be infinite")
  }
  
  func testSquareSizeWithNaN() {
    let size = CGSize(size: .nan)
    
    XCTAssertTrue(size.width.isNaN, "Width should be NaN")
    XCTAssertTrue(size.height.isNaN, "Height should be NaN")
  }
}

#endif

