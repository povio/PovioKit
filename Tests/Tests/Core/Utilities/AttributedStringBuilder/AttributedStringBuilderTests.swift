//
//  AttributedStringBuilderTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import UIKit
import PovioKitUtilities

final class AttributedStringBuilderTests: XCTestCase {
  
  // MARK: - Basic Initialization
  
  func testBuilderInitialization() {
    let builder = AttributedStringBuilder()
    XCTAssertNotNil(builder, "AttributedStringBuilder should initialize")
  }
  
  func testBuilderTextInitialization() {
    let text = "Hello World"
    let textBuilder = Builder(text: text)
    
    XCTAssertEqual(textBuilder.text, text, "Builder should store text")
  }
  
  // MARK: - Basic Apply Methods
  
  func testApplyWithText() {
    let builder = AttributedStringBuilder()
    let attributedString = builder.apply(on: "Hello World") { builder in
      builder.setFont(.systemFont(ofSize: 16))
    }
    
    XCTAssertEqual(attributedString.string, "Hello World", "Should create attributed string")
    XCTAssertNotNil(attributedString.attribute(.font, at: 0, effectiveRange: nil), "Should have font attribute")
  }
  
  func testApplyWithoutExplicitText() {
    let builder = AttributedStringBuilder()
    let attributedString = builder.apply { builder in
      builder.setTextColor(.red)
    }
    
    XCTAssertEqual(attributedString.string, "", "Should handle empty text")
  }
  
  func testCreateBasicAttributedString() {
    let textBuilder = Builder(text: "Test")
    let attributedString = textBuilder.create()
    
    XCTAssertEqual(attributedString.string, "Test", "Should create string")
  }
  
  func testCreateMutableAttributedString() {
    let textBuilder = Builder(text: "Test")
    let mutableString = textBuilder.createMutable()
    
    XCTAssertEqual(mutableString.string, "Test", "Should preserve text")
    // Verify it's mutable by appending
    mutableString.append(NSAttributedString(string: "!"))
    XCTAssertEqual(mutableString.string, "Test!", "Should be mutable")
  }
  
  // MARK: - Global Font Attributes
  
  func testSetFont() {
    let font = UIFont.systemFont(ofSize: 20)
    let attributedString = Builder(text: "Hello")
      .setFont(font)
      .create()
    
    let resultFont = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    XCTAssertEqual(resultFont, font, "Should set font")
  }
  
  func testSetFontWithNil() {
    let attributedString = Builder(text: "Hello")
      .setFont(nil)
      .create()
    
    let resultFont = attributedString.attribute(.font, at: 0, effectiveRange: nil)
    XCTAssertNil(resultFont, "Should handle nil font")
  }
  
  // MARK: - Global Color Attributes
  
  func testSetTextColor() {
    let color = UIColor.red
    let attributedString = Builder(text: "Hello")
      .setTextColor(color)
      .create()
    
    let resultColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    XCTAssertEqual(resultColor, color, "Should set text color")
  }
  
  func testSetTextColorWithNil() {
    let attributedString = Builder(text: "Hello")
      .setTextColor(nil)
      .create()
    
    let resultColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil)
    XCTAssertNil(resultColor, "Should handle nil color")
  }
  
  // MARK: - Global Underline Attributes
  
  func testSetUnderlineStyle() {
    let attributedString = Builder(text: "Hello")
      .setUnderlineStyle(.single)
      .create()
    
    let underline = attributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int
    XCTAssertEqual(underline, NSUnderlineStyle.single.rawValue, "Should set underline style")
  }
  
  func testSetUnderlineStyleDouble() {
    let attributedString = Builder(text: "Hello")
      .setUnderlineStyle(.double)
      .create()
    
    let underline = attributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int
    XCTAssertEqual(underline, NSUnderlineStyle.double.rawValue, "Should set double underline")
  }
  
  // MARK: - Global Paragraph Style
  
  func testSetParagraphStyle() {
    let attributedString = Builder(text: "Hello\nWorld")
      .setParagraphStyle(lineSpacing: 5, lineHeight: 20)
      .create()
    
    let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    XCTAssertNotNil(paragraphStyle, "Should set paragraph style")
    XCTAssertEqual(paragraphStyle?.lineSpacing, 5, "Should set line spacing")
    XCTAssertEqual(paragraphStyle?.minimumLineHeight, 20, "Should set line height")
  }
  
  func testSetParagraphStyleWithAlignment() {
    let attributedString = Builder(text: "Centered")
      .setParagraphStyle(lineSpacing: 0, lineHeight: 10, textAlignment: .center)
      .create()
    
    let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    XCTAssertEqual(paragraphStyle?.alignment, .center, "Should set text alignment")
  }
  
  func testSetParagraphStyleWithLineBreakMode() {
    let attributedString = Builder(text: "Long text")
      .setParagraphStyle(lineSpacing: 0, lineHeight: 10, lineBreakMode: .byTruncatingTail)
      .create()
    
    let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    XCTAssertEqual(paragraphStyle?.lineBreakMode, .byTruncatingTail, "Should set line break mode")
  }
  
  // MARK: - Range-Based Font Attributes
  
  func testSetFontWithRange() {
    let font = UIFont.boldSystemFont(ofSize: 18)
    let attributedString = Builder(text: "Hello World")
      .setFont(font, range: NSRange(location: 0, length: 5))
      .create()
    
    let resultFont = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    XCTAssertEqual(resultFont, font, "Should set font for range")
    
    // Check that the rest doesn't have the attribute
    let noFont = attributedString.attribute(.font, at: 6, effectiveRange: nil)
    XCTAssertNil(noFont, "Should not apply font outside range")
  }
  
  func testSetFontWithInvalidRange() {
    let font = UIFont.systemFont(ofSize: 16)
    let attributedString = Builder(text: "Hello")
      .setFont(font, range: NSRange(location: 10, length: 5))
      .create()
    
    // Should not crash with invalid range
    XCTAssertEqual(attributedString.string, "Hello", "Should handle invalid range gracefully")
  }
  
  // MARK: - Range-Based Color Attributes
  
  func testSetTextColorWithRange() {
    let color = UIColor.blue
    let attributedString = Builder(text: "Hello World")
      .setTextColor(color, range: NSRange(location: 6, length: 5))
      .create()
    
    let resultColor = attributedString.attribute(.foregroundColor, at: 6, effectiveRange: nil) as? UIColor
    XCTAssertEqual(resultColor, color, "Should set color for range")
  }
  
  // MARK: - Range-Based Underline Attributes
  
  func testSetUnderlineStyleWithRange() {
    let attributedString = Builder(text: "Hello World")
      .setUnderlineStyle(.single, range: NSRange(location: 0, length: 5))
      .create()
    
    let underline = attributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int
    XCTAssertEqual(underline, NSUnderlineStyle.single.rawValue, "Should set underline for range")
  }
  
  // MARK: - Range-Based Paragraph Style
  
  func testSetParagraphStyleWithRange() {
    let attributedString = Builder(text: "Hello World")
      .setParagraphStyle(lineSpacing: 10, lineHeight: 20, range: NSRange(location: 0, length: 5))
      .create()
    
    let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    XCTAssertNotNil(paragraphStyle, "Should set paragraph style for range")
    XCTAssertEqual(paragraphStyle?.lineSpacing, 10, "Should set line spacing")
  }
  
  // MARK: - Substring-Based Font Attributes
  
  func testSetFontWithSubstring() {
    let font = UIFont.boldSystemFont(ofSize: 20)
    let attributedString = Builder(text: "Hello World")
      .setFont(font, substring: "World")
      .create()
    
    let resultFont = attributedString.attribute(.font, at: 6, effectiveRange: nil) as? UIFont
    XCTAssertEqual(resultFont, font, "Should set font for substring")
  }
  
  func testSetFontWithNonExistentSubstring() {
    let font = UIFont.systemFont(ofSize: 16)
    let attributedString = Builder(text: "Hello World")
      .setFont(font, substring: "Foo")
      .create()
    
    // Should not crash with non-existent substring
    XCTAssertEqual(attributedString.string, "Hello World", "Should handle missing substring gracefully")
  }
  
  // MARK: - Substring-Based Color Attributes
  
  func testSetTextColorWithSubstring() {
    let color = UIColor.green
    let attributedString = Builder(text: "Hello World")
      .setTextColor(color, substring: "Hello")
      .create()
    
    let resultColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    XCTAssertEqual(resultColor, color, "Should set color for substring")
  }
  
  // MARK: - Substring-Based Underline Attributes
  
  func testSetUnderlineStyleWithSubstring() {
    let attributedString = Builder(text: "Hello World")
      .setUnderlineStyle(.single, substring: "World")
      .create()
    
    let underline = attributedString.attribute(.underlineStyle, at: 6, effectiveRange: nil) as? Int
    XCTAssertEqual(underline, NSUnderlineStyle.single.rawValue, "Should set underline for substring")
  }
  
  // MARK: - Substring-Based Paragraph Style
  
  func testSetParagraphStyleWithSubstring() {
    let attributedString = Builder(text: "Hello World")
      .setParagraphStyle(lineSpacing: 8, lineHeight: 16, substring: "Hello")
      .create()
    
    let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
    XCTAssertNotNil(paragraphStyle, "Should set paragraph style for substring")
  }
  
  // MARK: - Custom Attributes
  
  func testAddCustomAttribute() {
    let attributedString = Builder(text: "Hello")
      .addAttribute(key: .link, object: URL(string: "https://example.com"))
      .create()
    
    let link = attributedString.attribute(.link, at: 0, effectiveRange: nil) as? URL
    XCTAssertEqual(link?.absoluteString, "https://example.com", "Should add custom attribute")
  }
  
  func testAddCustomAttributeWithNil() {
    let attributedString = Builder(text: "Hello")
      .addAttribute(key: .link, object: nil)
      .create()
    
    let link = attributedString.attribute(.link, at: 0, effectiveRange: nil)
    XCTAssertNil(link, "Should handle nil custom attribute")
  }
  
  func testAddCustomAttributeWithRange() {
    let attributedString = Builder(text: "Hello World")
      .addAttribute(key: .link, object: URL(string: "https://example.com"), range: NSRange(location: 6, length: 5))
      .create()
    
    let link = attributedString.attribute(.link, at: 6, effectiveRange: nil) as? URL
    XCTAssertNotNil(link, "Should add custom attribute with range")
  }
  
  func testAddCustomAttributeWithSubstring() {
    let attributedString = Builder(text: "Hello World")
      .addAttribute(key: .link, object: URL(string: "https://example.com"), substring: "World")
      .create()
    
    let link = attributedString.attribute(.link, at: 6, effectiveRange: nil) as? URL
    XCTAssertNotNil(link, "Should add custom attribute with substring")
  }
  
  // MARK: - Chaining Multiple Attributes
  
  func testChainingMultipleAttributes() {
    let font = UIFont.boldSystemFont(ofSize: 18)
    let color = UIColor.red
    
    let attributedString = Builder(text: "Hello")
      .setFont(font)
      .setTextColor(color)
      .setUnderlineStyle(.single)
      .create()
    
    let resultFont = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    let resultColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    let underline = attributedString.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int
    
    XCTAssertEqual(resultFont, font, "Should chain font")
    XCTAssertEqual(resultColor, color, "Should chain color")
    XCTAssertEqual(underline, NSUnderlineStyle.single.rawValue, "Should chain underline")
  }
  
  func testChainingGlobalAndRangeAttributes() {
    let globalFont = UIFont.systemFont(ofSize: 14)
    let rangeFont = UIFont.boldSystemFont(ofSize: 20)
    
    let attributedString = Builder(text: "Hello World")
      .setFont(globalFont)
      .setFont(rangeFont, range: NSRange(location: 6, length: 5))
      .create()
    
    let globalResult = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    let rangeResult = attributedString.attribute(.font, at: 6, effectiveRange: nil) as? UIFont
    
    XCTAssertEqual(globalResult, globalFont, "Should have global font")
    XCTAssertEqual(rangeResult, rangeFont, "Should have range font")
  }
  
  // MARK: - Complex Scenarios
  
  func testComplexAttributedString() {
    let attributedString = Builder(text: "Title: Important Message")
      .setFont(.systemFont(ofSize: 14))
      .setTextColor(.black)
      .setFont(.boldSystemFont(ofSize: 18), substring: "Title:")
      .setTextColor(.red, substring: "Important")
      .setUnderlineStyle(.single, substring: "Message")
      .create()
    
    XCTAssertEqual(attributedString.string, "Title: Important Message")
    
    // Verify "Title:" is bold
    let titleFont = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    XCTAssertNotNil(titleFont, "Title should have font")
    
    // Verify "Important" is red
    let importantColor = attributedString.attribute(.foregroundColor, at: 7, effectiveRange: nil) as? UIColor
    XCTAssertEqual(importantColor, .red, "Important should be red")
    
    // Verify "Message" is underlined
    let messageUnderline = attributedString.attribute(.underlineStyle, at: 17, effectiveRange: nil) as? Int
    XCTAssertNotNil(messageUnderline, "Message should be underlined")
  }
  
  func testOverlappingAttributes() {
    let attributedString = Builder(text: "Hello World")
      .setTextColor(.red)
      .setTextColor(.blue, range: NSRange(location: 0, length: 5))
      .create()
    
    let blueColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    let redColor = attributedString.attribute(.foregroundColor, at: 6, effectiveRange: nil) as? UIColor
    
    XCTAssertEqual(blueColor, .blue, "Range attribute should override for 'Hello'")
    XCTAssertEqual(redColor, .red, "Global attribute should apply to 'World'")
  }
  
  // MARK: - Edge Cases
  
  func testEmptyString() {
    let attributedString = Builder(text: "")
      .setFont(.systemFont(ofSize: 16))
      .create()
    
    XCTAssertEqual(attributedString.string, "", "Should handle empty string")
    XCTAssertEqual(attributedString.length, 0, "Length should be zero")
  }
  
  func testVeryLongString() {
    let longText = String(repeating: "A", count: 10000)
    let attributedString = Builder(text: longText)
      .setFont(.systemFont(ofSize: 12))
      .create()
    
    XCTAssertEqual(attributedString.string.count, 10000, "Should handle long strings")
  }
  
  func testUnicodeCharacters() {
    let text = "Hello 👋 World 🌍"
    let attributedString = Builder(text: text)
      .setFont(.systemFont(ofSize: 16))
      .create()
    
    XCTAssertEqual(attributedString.string, text, "Should handle unicode characters")
  }
  
  func testMultipleSubstringMatches() {
    let attributedString = Builder(text: "Hello Hello Hello")
      .setTextColor(.red, substring: "Hello")
      .create()
    
    // Should only match the first occurrence
    let firstColor = attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    XCTAssertEqual(firstColor, .red, "Should color first Hello")
  }
  
  // MARK: - Mutable String Tests
  
  func testCreateMutableString() {
    let mutableString = Builder(text: "Hello")
      .setFont(.systemFont(ofSize: 16))
      .createMutable()
    
    // Verify it's actually mutable by appending
    mutableString.append(NSAttributedString(string: " World"))
    XCTAssertEqual(mutableString.string, "Hello World", "Should be mutable")
  }
  
  func testMutableStringWithRangeAttributes() {
    let mutableString = Builder(text: "Hello")
      .setFont(.systemFont(ofSize: 14))
      .setTextColor(.red, range: NSRange(location: 0, length: 5))
      .createMutable()
    
    let color = mutableString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    XCTAssertEqual(color, .red, "Mutable string should preserve range attributes")
  }
  
  // MARK: - Discardable Result
  
  func testDiscardableResultPattern() {
    // Should compile without warnings when result is not used
    _ = Builder(text: "Test")
      .setFont(.systemFont(ofSize: 16))
      .setTextColor(.black)
    
    XCTAssertTrue(true, "Discardable result should work")
  }
}

#endif
