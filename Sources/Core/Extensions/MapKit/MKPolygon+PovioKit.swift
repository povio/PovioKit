//
//  MKPolygon+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import MapKit.MKPolygon

public extension MKPolygon {
  /// Returns Bool to check if given `coordinate` exists in polygon
  func contains(coordinate: CLLocationCoordinate2D) -> Bool {
    // A polygon needs at least 3 points; the renderer's (implicitly unwrapped) path is nil otherwise.
    guard pointCount >= 3 else { return false }
    let polygonRenderer = MKPolygonRenderer(polygon: self)
    let currentMapPoint = MKMapPoint(coordinate)
    let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
    guard let path = polygonRenderer.path else { return false }
    return path.contains(polygonViewPoint, using: .evenOdd, transform: .identity)
  }
  
  /// Returns top/northern most coordinate for polygon
  var northernMostCoordinate: CLLocationCoordinate2D? {
    var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
    getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))
    guard !coordinates.isEmpty else { return nil }
    return coordinates.max { $0.latitude < $1.latitude }
  }
}
