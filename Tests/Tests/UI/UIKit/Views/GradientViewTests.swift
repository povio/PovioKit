//
//  GradientViewTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUIKit

@MainActor
final class GradientViewTests: XCTestCase {
  func test_initWithColors_setsGradientLayerColors() {
    let colors: [UIColor] = [.red, .blue]
    let view = GradientView(colors: colors)

    XCTAssertEqual(view.gradientLayer.colors as? [CGColor], colors.map { $0.cgColor })
  }

  func test_initWithColors_insertsGradientLayerAsBottomSublayer() {
    let view = GradientView(colors: [.red])

    XCTAssertTrue(view.layer.sublayers?.first === view.gradientLayer)
  }

  func test_initWithLayer_usesProvidedLayer() {
    let layer = CAGradientLayer()
    let view = GradientView(layer: layer)

    XCTAssertTrue(view.gradientLayer === layer)
  }

  func test_isShowingGradient_togglesLayerHidden() {
    let view = GradientView(colors: [.red])
    XCTAssertFalse(view.gradientLayer.isHidden)

    view.isShowingGradient = false
    XCTAssertTrue(view.gradientLayer.isHidden)

    view.isShowingGradient = true
    XCTAssertFalse(view.gradientLayer.isHidden)
  }

  func test_layoutSubviews_matchesGradientLayerFrameToBounds() {
    let view = GradientView(colors: [.red])
    view.frame = .init(x: 0, y: 0, width: 120, height: 40)

    view.layoutSubviews()

    XCTAssertEqual(view.gradientLayer.frame, view.bounds)
  }

  func test_setGradientColorsNil_clearsColorsAndLocations() {
    let view = GradientView(colors: [.red, .blue])
    view.setLocations(locations: [0, 1])

    view.setGradientColors(nil, animated: false)

    XCTAssertNil(view.gradientLayer.colors)
    XCTAssertNil(view.gradientLayer.locations)
  }

  func test_setGradientColorsUnanimated_setsColorsAndLocations() {
    let view = GradientView(colors: [.black])
    let colors: [UIColor] = [.green, .yellow]
    let locations: [NSNumber] = [0, 0.5]

    view.setGradientColors(colors, locations: locations, animated: false)

    XCTAssertEqual(view.gradientLayer.colors as? [CGColor], colors.map { $0.cgColor })
    XCTAssertEqual(view.gradientLayer.locations, locations)
  }

  func test_setGradientColorsAnimated_addsColorAndLocationAnimations() {
    let view = GradientView(colors: [.black])

    view.setGradientColors([.green, .yellow], locations: [0, 1], animated: true)

    XCTAssertNotNil(view.gradientLayer.animation(forKey: "colorChange"))
    XCTAssertNotNil(view.gradientLayer.animation(forKey: "locationsChange"))
  }

  func test_setLocations_setsGradientLayerLocations() {
    let view = GradientView(colors: [.red, .blue])

    view.setLocations(locations: [0.25, 0.75])

    XCTAssertEqual(view.gradientLayer.locations, [0.25, 0.75])
  }

  func test_setGradient_setsStartAndEndPoints() {
    let view = GradientView(colors: [.red])

    view.setGradient(startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))

    XCTAssertEqual(view.gradientLayer.startPoint, .init(x: 0, y: 0))
    XCTAssertEqual(view.gradientLayer.endPoint, .init(x: 1, y: 1))
  }
}

#endif
