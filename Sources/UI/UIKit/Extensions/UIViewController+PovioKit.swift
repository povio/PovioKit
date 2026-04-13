//
//  UIViewController+PovioKit.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/07/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIViewController {
  class BarButton {
    let content: Content
    let action: Selector?
    let target: Any?
    
    required public init(content: Content, action: Selector?, target: Any? = nil) {
      self.content = content
      self.action = action
      self.target = target
    }
  }
}

public extension UIViewController.BarButton {
  enum Content {
    case icon(UIImage)
    case title(Title)
    
    public static func icon(_ image: UIImage?) -> Content {
      .icon(image ?? UIImage())
    }
  }
}

public extension UIViewController.BarButton.Content {
  enum Title {
    case `default`(String)
    case attributed(normal: NSAttributedString, disabled: NSAttributedString?)
    
    public static func attributed(normal: NSAttributedString) -> Title {
      .attributed(normal: normal, disabled: nil)
    }
  }
}

public extension UIViewController {
  @discardableResult
  func setLeftBarButton(_ barButton: BarButton) -> UIBarButtonItem {
    let button = createButton(using: barButton)
    navigationItem.leftBarButtonItem = button
    return button
  }
  
  @discardableResult
  func setRightBarButton(_ barButton: BarButton) -> UIBarButtonItem {
    let button = createButton(using: barButton)
    navigationItem.rightBarButtonItem = button
    return button
  }
  
  @discardableResult
  func setLeftBarButtons(_ barButtons: [BarButton]) -> [UIBarButtonItem] {
    let buttons = barButtons.map(createButton)
    navigationItem.leftBarButtonItems = buttons
    return buttons
  }
  
  @discardableResult
  func setRightBarButtons(_ barButtons: [BarButton]) -> [UIBarButtonItem] {
    let buttons = barButtons.map(createButton)
    navigationItem.rightBarButtonItems = buttons
    return buttons
  }
}

private extension UIViewController {
  func createButton(using barButton: BarButton) -> UIBarButtonItem {
    switch barButton.content {
    case .title(.default(let title)):
      let button = UIButton()
      button.setTitle(title, for: .normal)
      barButton.action.map {
        button.addTarget(barButton.target ?? self, action: $0, for: .touchUpInside)
      }
      return UIBarButtonItem(customView: button)
    case let .title(.attributed(normal, disabled)):
      let button = UIButton()
      button.setAttributedTitle(normal, for: .normal)
      button.setAttributedTitle(disabled, for: .disabled)
      barButton.action.map {
        button.addTarget(barButton.target ?? self, action: $0, for: .touchUpInside)
      }
      return UIBarButtonItem(customView: button)
    case .icon(let image):
      return UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                             style: .plain,
                             target: barButton.target ?? self,
                             action: barButton.action)
    }
  }
}

#endif
