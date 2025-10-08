//
//  DoubleConversionTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class DoubleConversionTests: XCTestCase {
  
  // MARK: - Length Conversions
  
  func testMetersToFeet() {
    let meters: Double = 100
    let feet = meters.convert(from: UnitLength.meters, to: UnitLength.feet)
    
    // 100 meters ≈ 328.084 feet
    XCTAssertEqual(feet, 328.084, accuracy: 0.001, "100 meters should be ~328.084 feet")
  }
  
  func testFeetToMeters() {
    let feet: Double = 100
    let meters = feet.convert(from: UnitLength.feet, to: UnitLength.meters)
    
    // 100 feet ≈ 30.48 meters
    XCTAssertEqual(meters, 30.48, accuracy: 0.01, "100 feet should be ~30.48 meters")
  }
  
  func testKilometersToMiles() {
    let kilometers: Double = 10
    let miles = kilometers.convert(from: UnitLength.kilometers, to: UnitLength.miles)
    
    // 10 km ≈ 6.21371 miles
    XCTAssertEqual(miles, 6.21371, accuracy: 0.001, "10 km should be ~6.21371 miles")
  }
  
  func testMilesToKilometers() {
    let miles: Double = 10
    let kilometers = miles.convert(from: UnitLength.miles, to: UnitLength.kilometers)
    
    // 10 miles ≈ 16.0934 km
    XCTAssertEqual(kilometers, 16.0934, accuracy: 0.001, "10 miles should be ~16.0934 km")
  }
  
  func testInchesToCentimeters() {
    let inches: Double = 12
    let centimeters = inches.convert(from: UnitLength.inches, to: UnitLength.centimeters)
    
    // 12 inches = 30.48 cm
    XCTAssertEqual(centimeters, 30.48, accuracy: 0.01, "12 inches should be ~30.48 cm")
  }
  
  // MARK: - Mass Conversions
  
  func testKilogramsToPounds() {
    let kilograms: Double = 100
    let pounds = kilograms.convert(from: UnitMass.kilograms, to: UnitMass.pounds)
    
    // 100 kg ≈ 220.462 pounds
    XCTAssertEqual(pounds, 220.462, accuracy: 0.001, "100 kg should be ~220.462 pounds")
  }
  
  func testPoundsToKilograms() {
    let pounds: Double = 100
    let kilograms = pounds.convert(from: UnitMass.pounds, to: UnitMass.kilograms)
    
    // 100 pounds ≈ 45.3592 kg
    XCTAssertEqual(kilograms, 45.3592, accuracy: 0.001, "100 pounds should be ~45.3592 kg")
  }
  
  func testOuncesToGrams() {
    let ounces: Double = 16
    let grams = ounces.convert(from: UnitMass.ounces, to: UnitMass.grams)
    
    // 16 ounces ≈ 453.592 grams (1 pound)
    XCTAssertEqual(grams, 453.592, accuracy: 0.001, "16 ounces should be ~453.592 grams")
  }
  
  // MARK: - Temperature Conversions
  
  func testCelsiusToFahrenheit() {
    let celsius: Double = 100
    let fahrenheit = celsius.convert(from: UnitTemperature.celsius, to: UnitTemperature.fahrenheit)
    
    // 100°C = 212°F (boiling point of water)
    XCTAssertEqual(fahrenheit, 212, accuracy: 0.01, "100°C should be 212°F")
  }
  
  func testFahrenheitToCelsius() {
    let fahrenheit: Double = 32
    let celsius = fahrenheit.convert(from: UnitTemperature.fahrenheit, to: UnitTemperature.celsius)
    
    // 32°F = 0°C (freezing point of water)
    XCTAssertEqual(celsius, 0, accuracy: 0.01, "32°F should be 0°C")
  }
  
  func testCelsiusToKelvin() {
    let celsius: Double = 0
    let kelvin = celsius.convert(from: UnitTemperature.celsius, to: UnitTemperature.kelvin)
    
    // 0°C = 273.15 K
    XCTAssertEqual(kelvin, 273.15, accuracy: 0.01, "0°C should be 273.15 K")
  }
  
  // MARK: - Speed Conversions
  
  func testMetersPerSecondToKilometersPerHour() {
    let mps: Double = 10
    let kph = mps.convert(from: UnitSpeed.metersPerSecond, to: UnitSpeed.kilometersPerHour)
    
    // 10 m/s = 36 km/h
    XCTAssertEqual(kph, 36, accuracy: 0.01, "10 m/s should be 36 km/h")
  }
  
  func testMilesPerHourToKilometersPerHour() {
    let mph: Double = 60
    let kph = mph.convert(from: UnitSpeed.milesPerHour, to: UnitSpeed.kilometersPerHour)
    
    // 60 mph ≈ 96.56 km/h
    XCTAssertEqual(kph, 96.56, accuracy: 0.1, "60 mph should be ~96.56 km/h")
  }
  
  // MARK: - Volume Conversions
  
  func testLitersToGallons() {
    let liters: Double = 10
    let gallons = liters.convert(from: UnitVolume.liters, to: UnitVolume.gallons)
    
    // 10 liters ≈ 2.64172 gallons (US)
    XCTAssertEqual(gallons, 2.64172, accuracy: 0.001, "10 liters should be ~2.64172 gallons")
  }
  
  func testGallonsToLiters() {
    let gallons: Double = 5
    let liters = gallons.convert(from: UnitVolume.gallons, to: UnitVolume.liters)
    
    // 5 gallons ≈ 18.9271 liters
    XCTAssertEqual(liters, 18.9271, accuracy: 0.001, "5 gallons should be ~18.9271 liters")
  }
  
  func testMillilitersToFluidOunces() {
    let milliliters: Double = 500
    let fluidOunces = milliliters.convert(from: UnitVolume.milliliters, to: UnitVolume.fluidOunces)
    
    // 500 ml ≈ 16.907 fl oz
    XCTAssertEqual(fluidOunces, 16.907, accuracy: 0.001, "500 ml should be ~16.907 fl oz")
  }
  
  // MARK: - Same Unit Conversions (Identity)
  
  func testSameUnitConversion() {
    let meters: Double = 100
    let result = meters.convert(from: UnitLength.meters, to: UnitLength.meters)
    
    XCTAssertEqual(result, meters, accuracy: 0.0001, "Converting to same unit should return same value")
  }
  
  func testSameUnitConversionWithDifferentValue() {
    let kilograms: Double = 42.5
    let result = kilograms.convert(from: UnitMass.kilograms, to: UnitMass.kilograms)
    
    XCTAssertEqual(result, kilograms, accuracy: 0.0001, "Converting to same unit should preserve exact value")
  }
  
  // MARK: - Edge Cases
  
  func testZeroConversion() {
    let zero: Double = 0
    let result = zero.convert(from: UnitLength.meters, to: UnitLength.feet)
    
    XCTAssertEqual(result, 0, accuracy: 0.0001, "Zero should convert to zero")
  }
  
  func testNegativeValueConversion() {
    let negative: Double = -10
    let result = negative.convert(from: UnitTemperature.celsius, to: UnitTemperature.fahrenheit)
    
    // -10°C = 14°F
    XCTAssertEqual(result, 14, accuracy: 0.01, "-10°C should be 14°F")
  }
  
  func testVeryLargeNumberConversion() {
    let large: Double = 1_000_000
    let result = large.convert(from: UnitLength.meters, to: UnitLength.kilometers)
    
    XCTAssertEqual(result, 1000, accuracy: 0.01, "1,000,000 meters should be 1,000 kilometers")
  }
  
  func testVerySmallNumberConversion() {
    let small: Double = 0.001
    let result = small.convert(from: UnitLength.kilometers, to: UnitLength.meters)
    
    XCTAssertEqual(result, 1, accuracy: 0.0001, "0.001 km should be 1 meter")
  }
  
  func testDecimalPrecision() {
    let precise: Double = 1.23456789
    let result = precise.convert(from: UnitLength.meters, to: UnitLength.centimeters)
    
    // 1.23456789 meters = 123.456789 cm
    XCTAssertEqual(result, 123.456789, accuracy: 0.000001, "Should maintain decimal precision")
  }
  
  // MARK: - Chain Conversions
  
  func testChainConversion() {
    let meters: Double = 1000
    
    // Convert meters -> kilometers -> miles
    let kilometers = meters.convert(from: UnitLength.meters, to: UnitLength.kilometers)
    let miles = kilometers.convert(from: UnitLength.kilometers, to: UnitLength.miles)
    
    // 1000 meters = 1 km ≈ 0.621371 miles
    XCTAssertEqual(kilometers, 1, accuracy: 0.0001, "1000 meters should be 1 km")
    XCTAssertEqual(miles, 0.621371, accuracy: 0.001, "1 km should be ~0.621371 miles")
  }
  
  func testRoundTripConversion() {
    let original: Double = 42.5
    
    // Convert kg -> lbs -> kg
    let pounds = original.convert(from: UnitMass.kilograms, to: UnitMass.pounds)
    let backToKg = pounds.convert(from: UnitMass.pounds, to: UnitMass.kilograms)
    
    XCTAssertEqual(backToKg, original, accuracy: 0.0001, "Round-trip conversion should return to original value")
  }
}

