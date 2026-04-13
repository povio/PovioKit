//
//  ColorInterpolatorTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitUtilities

final class ColorInterpolatorTests: XCTestCase {
  var interpolator: LinearColorInterpolator!
  
  override func setUp() {
    super.setUp()
    interpolator = LinearColorInterpolator()
  }
  
  override func tearDown() {
    interpolator = nil
    super.tearDown()
  }
  
  // MARK: - Two Color Interpolation
  
  func testInterpolateBetweenBlackAndWhite() throws {
    // Use explicit RGB colors to ensure consistent color space
    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    // At 0%, should be black
    let color0 = try interpolator.interpolate(black, with: white, percentage: 0)
    XCTAssertEqual(color0.rgba.red, 0, accuracy: 0.01, "At 0%, red should be 0")
    XCTAssertEqual(color0.rgba.green, 0, accuracy: 0.01, "At 0%, green should be 0")
    XCTAssertEqual(color0.rgba.blue, 0, accuracy: 0.01, "At 0%, blue should be 0")
    
    // At 50%, should be gray
    let color50 = try interpolator.interpolate(black, with: white, percentage: 0.5)
    XCTAssertEqual(color50.rgba.red, 0.5, accuracy: 0.01, "At 50%, red should be ~0.5")
    XCTAssertEqual(color50.rgba.green, 0.5, accuracy: 0.01, "At 50%, green should be ~0.5")
    XCTAssertEqual(color50.rgba.blue, 0.5, accuracy: 0.01, "At 50%, blue should be ~0.5")
    
    // At 100%, should be white
    let color100 = try interpolator.interpolate(black, with: white, percentage: 1.0)
    XCTAssertEqual(color100.rgba.red, 1.0, accuracy: 0.01, "At 100%, red should be 1")
    XCTAssertEqual(color100.rgba.green, 1.0, accuracy: 0.01, "At 100%, green should be 1")
    XCTAssertEqual(color100.rgba.blue, 1.0, accuracy: 0.01, "At 100%, blue should be 1")
  }
  
  func testInterpolateBetweenRedAndBlue() throws {
    // Use explicit RGB colors to ensure consistent color space
    let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let blue = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    
    let color50 = try interpolator.interpolate(red, with: blue, percentage: 0.5)
    
    // Should be purple-ish (mix of red and blue)
    XCTAssertEqual(color50.rgba.red, 0.5, accuracy: 0.01, "Red component should be ~0.5")
    XCTAssertEqual(color50.rgba.green, 0, accuracy: 0.01, "Green component should be 0")
    XCTAssertEqual(color50.rgba.blue, 0.5, accuracy: 0.01, "Blue component should be ~0.5")
  }
  
  func testInterpolateWithPercentageClamping() throws {
    // Use explicit RGB colors to ensure consistent color space
    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    // Values below 0 should be clamped to 0
    let colorNegative = try interpolator.interpolate(black, with: white, percentage: -0.5)
    XCTAssertEqual(colorNegative.rgba.red, 0, accuracy: 0.01, "Negative percentage should clamp to 0%")
    
    // Values above 1 should be clamped to 1
    let colorOver = try interpolator.interpolate(black, with: white, percentage: 1.5)
    XCTAssertEqual(colorOver.rgba.red, 1.0, accuracy: 0.01, "Over 100% should clamp to 100%")
  }
  
  // MARK: - Multiple Color Interpolation
  
  func testInterpolateWithMultipleColorPoints() throws {
    // Use explicit RGB colors to ensure consistent color space
    let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let green = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let blue = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let colorPoints = [red, green, blue]
    
    // At 0%, should be red
    let color0 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 0)
    XCTAssertEqual(color0.rgba.red, 1.0, accuracy: 0.01, "At 0%, should be red")
    
    // At 50%, should be green
    let color50 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.5)
    XCTAssertEqual(color50.rgba.green, 1.0, accuracy: 0.1, "At 50%, should be mostly green")
    
    // At 100%, should be blue
    let color100 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 1.0)
    XCTAssertEqual(color100.rgba.blue, 1.0, accuracy: 0.01, "At 100%, should be blue")
  }
  
  func testInterpolateWithTwoColorPoints() throws {
    // Use explicit RGB colors to ensure consistent color space
    let black = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    let colorPoints = [black, white]
    
    let color50 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.5)
    XCTAssertEqual(color50.rgba.red, 0.5, accuracy: 0.01, "Should interpolate correctly with 2 colors")
  }
  
  func testInterpolateWithMultiplePointsEdgeCases() throws {
    // Use explicit RGB colors to ensure consistent color space
    let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let green = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let blue = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let colorPoints = [red, green, blue]
    
    // Very close to 0
    let colorAlmost0 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.005)
    XCTAssertEqual(colorAlmost0.rgba.red, 1.0, accuracy: 0.01, "Very close to 0% should return first color")
    
    // Very close to 1
    let colorAlmost100 = try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.995)
    XCTAssertEqual(colorAlmost100.rgba.blue, 1.0, accuracy: 0.01, "Very close to 100% should return last color")
  }
  
  // MARK: - Error Cases
  
  func testInterpolateWithInsufficientColorPoints() {
    let red = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let colorPoints = [red] // Only one color
    
    XCTAssertThrowsError(try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.5)) { error in
      XCTAssertTrue(error is LinearColorInterpolator.Error, "Should throw LinearColorInterpolator.Error")
      if let interpolatorError = error as? LinearColorInterpolator.Error {
        XCTAssertEqual(interpolatorError, .colorComponentsMissing, "Should throw colorComponentsMissing error")
      }
    }
  }
  
  func testInterpolateWithEmptyColorPoints() {
    let colorPoints: [UIColor] = []
    
    XCTAssertThrowsError(try interpolator.interpolate(colorPoints: colorPoints, percentage: 0.5)) { error in
      XCTAssertTrue(error is LinearColorInterpolator.Error, "Should throw LinearColorInterpolator.Error")
    }
  }
  
  // MARK: - Raw Component Interpolation
  
  func testInterpolateWithRawComponents() {
    let startComponents: [CGFloat] = [0, 0, 0] // Black
    let endComponents: [CGFloat] = [1, 1, 1]   // White
    
    let color50 = interpolator.interpolate(startComponents, with: endComponents, percentage: 0.5)
    
    XCTAssertEqual(color50.rgba.red, 0.5, accuracy: 0.01, "Red component should be ~0.5")
    XCTAssertEqual(color50.rgba.green, 0.5, accuracy: 0.01, "Green component should be ~0.5")
    XCTAssertEqual(color50.rgba.blue, 0.5, accuracy: 0.01, "Blue component should be ~0.5")
  }
  
  func testInterpolateWithRawComponentsClamping() {
    let startComponents: [CGFloat] = [0, 0, 0]
    let endComponents: [CGFloat] = [1, 1, 1]
    
    // Test clamping below 0
    let colorNegative = interpolator.interpolate(startComponents, with: endComponents, percentage: -0.5)
    XCTAssertEqual(colorNegative.rgba.red, 0, accuracy: 0.01, "Should clamp to 0")
    
    // Test clamping above 1
    let colorOver = interpolator.interpolate(startComponents, with: endComponents, percentage: 1.5)
    XCTAssertEqual(colorOver.rgba.red, 1.0, accuracy: 0.01, "Should clamp to 1")
  }
}

// MARK: - Helper Extensions

private extension UIColor {
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
  }
}
#endif

