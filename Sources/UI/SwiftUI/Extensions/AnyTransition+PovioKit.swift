//
//  AnyTransition+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

public extension AnyTransition {
  /// `slideLeft` is a inverse transition of system `slide`
  static var slideLeft: AnyTransition {
    .asymmetric(
      insertion: .move(edge: .trailing),
      removal: .move(edge: .leading)
    )
  }
}
