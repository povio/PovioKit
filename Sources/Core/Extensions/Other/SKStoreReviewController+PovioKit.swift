//
//  SKStoreReviewController+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 23/06/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import StoreKit

public extension SKStoreReviewController {
  /// Request a review popup on the current scene.
  ///
  /// Must be called from the main actor because both `UIApplication.shared`
  /// and `SKStoreReviewController.requestReview(in:)` are main-actor isolated.
  ///
  /// ## Example
  /// ```swift
  /// SKStoreReviewController.requestReviewInCurrentScene()
  /// ```
  @MainActor
  static func requestReviewInCurrentScene() {
    (UIApplication
      .shared
      .connectedScenes
      .first { $0.activationState == .foregroundActive } as? UIWindowScene
    ).map { requestReview(in: $0) }
  }
}
#endif
