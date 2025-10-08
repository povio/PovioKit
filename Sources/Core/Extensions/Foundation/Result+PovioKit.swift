//
//  Result+PovioKit.swift
//  Alamofire
//
//  Created by Borut Tomazin on 24/02/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension Result where Success == Void {
  /// Simplified `success` Result for Void types.
  static func success() -> Result {
    .success(())
  }
}
