//
//  PaddingLabel.swift
//  PovioKit
//
//  Created by Borut Tomazin on 13/05/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/// A UILabel subclass with configurable `contentInset`.
open class PaddingLabel: UILabel {
  public var contentInset: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5) {
    didSet { invalidateIntrinsicContentSize() }
  }
  
  override open func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: contentInset))
  }
  
  override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    super.textRect(forBounds: bounds.inset(by: contentInset), limitedToNumberOfLines: 0)
  }
  
  override open var intrinsicContentSize: CGSize {
    var contentSize = super.intrinsicContentSize
    contentSize.height += contentInset.top + contentInset.bottom
    contentSize.width += contentInset.left + contentInset.right
    return contentSize
  }
}

#endif
