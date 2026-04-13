//
//  UIProgressView+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 13/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIProgressView {
  /// A wrapper around the `setProgress(_ progress: Float, animated: Bool)` UIKit method that extra provides animation `duration` and completion.
  func setProgress(_ progress: Float, animated: Bool, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
    guard animated else {
      setProgress(progress, animated: false)
      completion?()
      return
    }
    
    UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: [], animations: {
      self.setProgress(progress, animated: true)
    }, completion: { _ in
      completion?()
    })
  }
}

#endif
