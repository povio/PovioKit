//
//  UIView+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIView {
  // Add shadow and border
  func dropShadow(path: UIBezierPath?, shadowColor: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
    layer.shadowPath = path?.cgPath
    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = offset
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
  }
  
  /// Apply border with given `color` and `width`.
  func applyBorder(color: UIColor, width: CGFloat) {
    layer.borderColor = color.cgColor
    layer.borderWidth = width
  }
  
  /// Toggles view visibility in animated fashion, for given `animationDuration`.
  @objc func setHidden(_ hidden: Bool, animationDuration: TimeInterval, completion: (() -> Void)? = nil) {
    guard isHidden != hidden else {
      completion?()
      return
    }
    
    switch hidden {
    case true:
      alpha = 1
    case false:
      alpha = 0
      isHidden = false
    }
    
    UIView.animate(withDuration: animationDuration, animations: {
      self.alpha = hidden ? 0 : 1
    }, completion: { _ in
      self.isHidden = hidden
      completion?()
    })
  }
}

// MARK: - Animations
public extension UIView {
  struct AnimationKey {
    public static let rotation = "rotationAnimationKey"
    public static let shadowOpacity = "shadowOpacityKey"
  }
  
  func rotate(speed: CFTimeInterval = 1.25, clockwise: Bool = true) {
    guard layer.animation(forKey: UIView.AnimationKey.rotation) == nil else { return }
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotationAnimation.fromValue = 0.0
    rotationAnimation.toValue = (Float.pi * 2.0) * (clockwise ? 1 : -1)
    rotationAnimation.duration = speed
    rotationAnimation.repeatCount = Float.infinity
    layer.add(rotationAnimation, forKey: UIView.AnimationKey.rotation)
  }
  
  func stopRotating() {
    if layer.animation(forKey: UIView.AnimationKey.rotation) != nil {
      layer.removeAnimation(forKey: UIView.AnimationKey.rotation)
    }
  }
}

#endif
