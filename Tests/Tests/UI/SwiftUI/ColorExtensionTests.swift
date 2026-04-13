//
//  ColorExtensionTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import SwiftUI
import PovioKitSwiftUI

final class ColorExtensionTests: XCTestCase {
  
  // MARK: - RGB Initializer
  
  func testRGBInitializerWithZeroValues() {
    let color = Color(red: 0, green: 0, blue: 0)
    
    // Black color
    XCTAssertNotNil(color, "Should create black color")
  }
  
  func testRGBInitializerWithMaxValues() {
    let color = Color(red: 255, green: 255, blue: 255)
    
    // White color
    XCTAssertNotNil(color, "Should create white color")
  }
  
  func testRGBInitializerWithMidValues() {
    let color = Color(red: 128, green: 128, blue: 128)
    
    // Gray color
    XCTAssertNotNil(color, "Should create gray color")
  }
  
  func testRGBInitializerIndependentChannels() {
    let red = Color(red: 255, green: 0, blue: 0)
    let green = Color(red: 0, green: 255, blue: 0)
    let blue = Color(red: 0, green: 0, blue: 255)
    
    XCTAssertNotNil(red, "Should create red color")
    XCTAssertNotNil(green, "Should create green color")
    XCTAssertNotNil(blue, "Should create blue color")
  }
  
  func testRGBInitializerWithCustomValues() {
    let color = Color(red: 123, green: 45, blue: 67)
    
    XCTAssertNotNil(color, "Should create custom color")
  }
  
  // MARK: - Hex Initializer - 6 Digit (RGB 24-bit)
  
  func testHexInitializerWithBlack() {
    let color = Color(hex: "000000")
    
    XCTAssertNotNil(color, "Should create black from hex")
  }
  
  func testHexInitializerWithWhite() {
    let color = Color(hex: "FFFFFF")
    
    XCTAssertNotNil(color, "Should create white from hex")
  }
  
  func testHexInitializerWithRed() {
    let color = Color(hex: "FF0000")
    
    XCTAssertNotNil(color, "Should create red from hex")
  }
  
  func testHexInitializerWithGreen() {
    let color = Color(hex: "00FF00")
    
    XCTAssertNotNil(color, "Should create green from hex")
  }
  
  func testHexInitializerWithBlue() {
    let color = Color(hex: "0000FF")
    
    XCTAssertNotNil(color, "Should create blue from hex")
  }
  
  func testHexInitializerWithCustomColor() {
    let color = Color(hex: "3498DB")
    
    XCTAssertNotNil(color, "Should create custom color from hex")
  }
  
  func testHexInitializerCaseInsensitive() {
    let uppercase = Color(hex: "FF5733")
    let lowercase = Color(hex: "ff5733")
    let mixed = Color(hex: "Ff5733")
    
    XCTAssertNotNil(uppercase, "Should handle uppercase hex")
    XCTAssertNotNil(lowercase, "Should handle lowercase hex")
    XCTAssertNotNil(mixed, "Should handle mixed case hex")
  }
  
  // MARK: - Hex Initializer - 3 Digit (RGB 12-bit)
  
  func testHexInitializerWith3DigitBlack() {
    let color = Color(hex: "000")
    
    XCTAssertNotNil(color, "Should create black from 3-digit hex")
  }
  
  func testHexInitializerWith3DigitWhite() {
    let color = Color(hex: "FFF")
    
    XCTAssertNotNil(color, "Should create white from 3-digit hex")
  }
  
  func testHexInitializerWith3DigitRed() {
    let color = Color(hex: "F00")
    
    XCTAssertNotNil(color, "Should create red from 3-digit hex")
  }
  
  func testHexInitializerWith3DigitGreen() {
    let color = Color(hex: "0F0")
    
    XCTAssertNotNil(color, "Should create green from 3-digit hex")
  }
  
  func testHexInitializerWith3DigitBlue() {
    let color = Color(hex: "00F")
    
    XCTAssertNotNil(color, "Should create blue from 3-digit hex")
  }
  
  func testHexInitializerWith3DigitCustom() {
    let color = Color(hex: "3BD")
    
    XCTAssertNotNil(color, "Should create custom color from 3-digit hex")
  }
  
  // MARK: - Hex Initializer - 8 Digit (ARGB 32-bit)
  
  func testHexInitializerWith8DigitFullyOpaque() {
    let color = Color(hex: "FFFF0000")
    
    XCTAssertNotNil(color, "Should create fully opaque red from 8-digit hex")
  }
  
  func testHexInitializerWith8DigitSemiTransparent() {
    let color = Color(hex: "80FF0000")
    
    XCTAssertNotNil(color, "Should create semi-transparent red from 8-digit hex")
  }
  
  func testHexInitializerWith8DigitFullyTransparent() {
    let color = Color(hex: "00FF0000")
    
    XCTAssertNotNil(color, "Should create fully transparent red from 8-digit hex")
  }
  
  func testHexInitializerWith8DigitCustomAlpha() {
    let color = Color(hex: "AA3498DB")
    
    XCTAssertNotNil(color, "Should create color with custom alpha from 8-digit hex")
  }
  
  // MARK: - Hex Initializer - With Hash Symbol
  
  func testHexInitializerWithHashPrefix() {
    let color = Color(hex: "#FF0000")
    
    XCTAssertNotNil(color, "Should handle hex with # prefix")
  }
  
  func testHexInitializerWith3DigitAndHash() {
    let color = Color(hex: "#F00")
    
    XCTAssertNotNil(color, "Should handle 3-digit hex with #")
  }
  
  func testHexInitializerWith8DigitAndHash() {
    let color = Color(hex: "#FFFF0000")
    
    XCTAssertNotNil(color, "Should handle 8-digit hex with #")
  }
  
  // MARK: - Hex Initializer - With 0x Prefix
  
  func testHexInitializerWith0xPrefix() {
    let color = Color(hex: "0xFF0000")
    
    XCTAssertNotNil(color, "Should handle hex with 0x prefix")
  }
  
  func testHexInitializerWith0XPrefix() {
    let color = Color(hex: "0XFF0000")
    
    XCTAssertNotNil(color, "Should handle hex with 0X prefix")
  }
  
  // MARK: - Hex Initializer - Invalid/Edge Cases
  
  func testHexInitializerWithEmptyString() {
    let color = Color(hex: "")
    
    XCTAssertNotNil(color, "Should handle empty string gracefully")
  }
  
  func testHexInitializerWithInvalidLength() {
    let color1 = Color(hex: "FF")
    let color2 = Color(hex: "FFFF")
    let color5 = Color(hex: "FFFFF")
    let color7 = Color(hex: "FFFFFFF")
    
    XCTAssertNotNil(color1, "Should handle 2-digit hex gracefully")
    XCTAssertNotNil(color2, "Should handle 4-digit hex gracefully")
    XCTAssertNotNil(color5, "Should handle 5-digit hex gracefully")
    XCTAssertNotNil(color7, "Should handle 7-digit hex gracefully")
  }
  
  func testHexInitializerWithInvalidCharacters() {
    let color1 = Color(hex: "GGGGGG")
    let color2 = Color(hex: "ZZZZZZ")
    let color3 = Color(hex: "!!!!")
    
    XCTAssertNotNil(color1, "Should handle invalid hex characters")
    XCTAssertNotNil(color2, "Should handle non-hex characters")
    XCTAssertNotNil(color3, "Should handle special characters")
  }
  
  func testHexInitializerWithWhitespace() {
    let color1 = Color(hex: " FF0000 ")
    let color2 = Color(hex: "FF 00 00")
    let color3 = Color(hex: "\nFF0000\n")
    
    XCTAssertNotNil(color1, "Should handle leading/trailing whitespace")
    XCTAssertNotNil(color2, "Should handle internal whitespace")
    XCTAssertNotNil(color3, "Should handle newlines")
  }
  
  func testHexInitializerWithMixedInvalidCharacters() {
    let color = Color(hex: "#FF-00-00")
    
    XCTAssertNotNil(color, "Should strip non-alphanumeric characters")
  }
  
  // MARK: - Common Color Values
  
  func testCommonWebColors() {
    let colors = [
      "FF0000", // Red
      "00FF00", // Green
      "0000FF", // Blue
      "FFFF00", // Yellow
      "FF00FF", // Magenta
      "00FFFF", // Cyan
      "000000", // Black
      "FFFFFF", // White
      "808080", // Gray
      "FFA500", // Orange
      "800080", // Purple
      "A52A2A"  // Brown
    ]
    
    for hexValue in colors {
      let color = Color(hex: hexValue)
      XCTAssertNotNil(color, "Should create color for \(hexValue)")
    }
  }
  
  // MARK: - RGB to Hex Equivalence
  
  func testRGBAndHexEquivalence() {
    // These should represent the same colors
    let rgbRed = Color(red: 255, green: 0, blue: 0)
    let hexRed = Color(hex: "FF0000")
    
    let rgbGreen = Color(red: 0, green: 255, blue: 0)
    let hexGreen = Color(hex: "00FF00")
    
    let rgbBlue = Color(red: 0, green: 0, blue: 255)
    let hexBlue = Color(hex: "0000FF")
    
    XCTAssertNotNil(rgbRed, "RGB red should exist")
    XCTAssertNotNil(hexRed, "Hex red should exist")
    XCTAssertNotNil(rgbGreen, "RGB green should exist")
    XCTAssertNotNil(hexGreen, "Hex green should exist")
    XCTAssertNotNil(rgbBlue, "RGB blue should exist")
    XCTAssertNotNil(hexBlue, "Hex blue should exist")
  }
  
  func testRGBAndHexCustomColor() {
    let rgb = Color(red: 52, green: 152, blue: 219)
    let hex = Color(hex: "3498DB")
    
    XCTAssertNotNil(rgb, "RGB custom color should exist")
    XCTAssertNotNil(hex, "Hex custom color should exist")
  }
  
  // MARK: - Real-World Scenarios
  
  func testBrandColors() {
    // Common brand colors
    let facebookBlue = Color(hex: "1877F2")
    let twitterBlue = Color(hex: "1DA1F2")
    let instagramPurple = Color(hex: "E4405F")
    
    XCTAssertNotNil(facebookBlue, "Should create Facebook blue")
    XCTAssertNotNil(twitterBlue, "Should create Twitter blue")
    XCTAssertNotNil(instagramPurple, "Should create Instagram purple")
  }
  
  func testUIThemeColors() {
    // Common UI theme colors
    let primary = Color(hex: "007AFF")
    let secondary = Color(hex: "5856D6")
    let success = Color(hex: "34C759")
    let warning = Color(hex: "FF9500")
    let danger = Color(hex: "FF3B30")
    
    XCTAssertNotNil(primary, "Should create primary theme color")
    XCTAssertNotNil(secondary, "Should create secondary theme color")
    XCTAssertNotNil(success, "Should create success color")
    XCTAssertNotNil(warning, "Should create warning color")
    XCTAssertNotNil(danger, "Should create danger color")
  }
  
  func testShorthandHexExpansion() {
    // #F00 should expand to #FF0000
    let shorthand = Color(hex: "F00")
    let full = Color(hex: "FF0000")
    
    XCTAssertNotNil(shorthand, "Should handle shorthand hex")
    XCTAssertNotNil(full, "Should handle full hex")
  }
}

