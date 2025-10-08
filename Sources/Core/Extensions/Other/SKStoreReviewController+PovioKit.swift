//
//  SKStoreReviewController+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 23/06/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import StoreKit

public extension SKStoreReviewController {
  /// Request a review popup on the current scene.
  ///
  /// ## Example
  /// ```swift
  /// SKStoreReviewController.requestReviewInCurrentScene()
  /// ```
  static func requestReviewInCurrentScene() {
    if #available(iOS 14.0, *) {
      (UIApplication
        .shared
        .connectedScenes
        .first { $0.activationState == .foregroundActive } as? UIWindowScene
      ).map { requestReview(in: $0) }
    } else {
      requestReview()
    }
  }
}
#endif
