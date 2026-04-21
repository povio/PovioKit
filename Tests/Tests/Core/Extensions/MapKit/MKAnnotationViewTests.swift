//
//  MKAnnotationViewTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 02/06/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import MapKit.MKAnnotationView

// `MKAnnotationView.identifier` is a `@MainActor`-isolated class
// property on recent SDKs, so the test method must be main-actor
// isolated to reference it.
@MainActor
class MKAnnotationViewTests: XCTestCase {
  func test_identifier_returnsCorrectIdentifier() {
    let SUTs: [(expectedIdentifier: String, mkAnnotationView: MKAnnotationView.Type)] = [("CustomMKAnnotationView", CustomMKAnnotationView.self), ("OtherMKAnnotationView", OtherMKAnnotationView.self)]
    
    for sut in SUTs {
      XCTAssertEqual(sut.expectedIdentifier, sut.mkAnnotationView.identifier)
    }
  }
}

// MARK: - Helpers
private class CustomMKAnnotationView: MKAnnotationView { }
private class OtherMKAnnotationView: MKAnnotationView { }
