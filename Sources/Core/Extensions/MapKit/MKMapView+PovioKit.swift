//
//  MKMapView+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import MapKit.MKMapView

public extension MKMapView {
  /// Returns radius distance in meters from map center to the top of the visible screen
  var visibleRadius: Double {
    let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
    let topCenterCoordinate = convert(.init(x: bounds.midX, y: 0), toCoordinateFrom: self)
    let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
    return centerLocation.distance(from: topCenterLocation)
  }
  
  /// Returns mapView center location
  var centerLocation: CLLocation {
    .init(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
  }
  
  /// Register cell for given `cell` class
  func register<T: MKAnnotationView>(view: T.Type) {
    register(view, forAnnotationViewWithReuseIdentifier: view.identifier)
  }
  
  /// Dequeue reusable annotation view
  func dequeueAnnotationView<T: MKAnnotationView>(_ view: T.Type, for annotation: MKAnnotation) -> T {
    guard let view = dequeueReusableAnnotationView(withIdentifier: T.identifier, for: annotation) as? T else {
      return T(annotation: annotation, reuseIdentifier: T.identifier)
    }
    return view
  }
}
