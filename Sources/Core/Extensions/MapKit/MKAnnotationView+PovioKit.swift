//
//  MKAnnotationView+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import MapKit.MKAnnotationView

public extension MKAnnotationView {
  static var identifier: String {
    .init(describing: self)
  }
}
