//
//  UIWindow+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 5/1/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIWindow {
  /// Returns `viewController` that currently sits on top
  var topViewController: UIViewController? {
    func topViewController(with rootViewController: UIViewController?) -> UIViewController? {
      guard rootViewController != nil else { return nil }
      
      if let tabBarController = rootViewController as? UITabBarController {
        return topViewController(with: tabBarController.selectedViewController)
      } else if let navigationController = rootViewController as? UINavigationController {
        return topViewController(with: navigationController.visibleViewController)
      } else if rootViewController?.presentedViewController != nil {
        return topViewController(with: rootViewController?.presentedViewController)
      }
      return rootViewController
    }
    return topViewController(with: rootViewController)
  }
}
#endif
