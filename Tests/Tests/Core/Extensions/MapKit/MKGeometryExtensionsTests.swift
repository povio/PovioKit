//
//  MKGeometryExtensionsTests.swift
//  PovioKit_Tests
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import MapKit

final class MKGeometryExtensionsTests: XCTestCase {
  func testMKCircleContainsCoordinate() {
    let center = CLLocationCoordinate2D(latitude: 46.0569, longitude: 14.5058)
    let circle = MKCircle(center: center, radius: 1_000)
    
    XCTAssertTrue(circle.contains(coordinate: center))
    XCTAssertFalse(circle.contains(coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 15.0)))
  }
  
  func testMKPolygonContainsAndNorthernMostCoordinate() throws {
    let coordinates = [
      CLLocationCoordinate2D(latitude: 45.0, longitude: 14.0),
      CLLocationCoordinate2D(latitude: 46.0, longitude: 15.0),
      CLLocationCoordinate2D(latitude: 45.5, longitude: 16.0),
      CLLocationCoordinate2D(latitude: 44.8, longitude: 14.8)
    ]
    let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
    
    XCTAssertTrue(polygon.contains(coordinate: CLLocationCoordinate2D(latitude: 45.3, longitude: 15.1)))
    XCTAssertFalse(polygon.contains(coordinate: CLLocationCoordinate2D(latitude: 47.0, longitude: 17.0)))
    let northernMostCoordinate = try XCTUnwrap(polygon.northernMostCoordinate)
    XCTAssertEqual(northernMostCoordinate.latitude, 46.0, accuracy: 0.000_1)
    XCTAssertEqual(northernMostCoordinate.longitude, 15.0, accuracy: 0.000_1)
  }
  
  func testMKMapViewHelpers() {
    let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let center = CLLocationCoordinate2D(latitude: 46.0569, longitude: 14.5058)
    mapView.setRegion(
      MKCoordinateRegion(center: center, latitudinalMeters: 1_000, longitudinalMeters: 1_000),
      animated: false
    )
    
    XCTAssertEqual(mapView.centerLocation.coordinate.latitude, center.latitude, accuracy: 0.1)
    XCTAssertEqual(mapView.centerLocation.coordinate.longitude, center.longitude, accuracy: 0.1)
    XCTAssertGreaterThan(mapView.visibleRadius, 0)
  }
  
  func testMKMapViewRegisterAndDequeueAnnotationView() {
    let mapView = MKMapView(frame: .init(x: 0, y: 0, width: 100, height: 100))
    mapView.register(view: TestAnnotationView.self)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: 46.0569, longitude: 14.5058)
    
    let view: TestAnnotationView = mapView.dequeueAnnotationView(TestAnnotationView.self, for: annotation)
    XCTAssertEqual(view.reuseIdentifier, TestAnnotationView.identifier)
  }
}

private final class TestAnnotationView: MKAnnotationView {}
