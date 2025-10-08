//
//  UITableViewHeaderFooterView+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UITableViewHeaderFooterView {
  /// Returns cell's reuse identifier
  static var identifier: String {
    String(describing: self)
  }
}

#endif
