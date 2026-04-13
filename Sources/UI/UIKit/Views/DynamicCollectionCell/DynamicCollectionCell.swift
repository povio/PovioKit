//
//  DynamicCollectionCell.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

open class DynamicCollectionCell: UICollectionViewCell {
  public var direction: Direction = .vertical
  
  override open func systemLayoutSizeFitting(_ targetSize: CGSize,
                                             withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                             verticalFittingPriority: UILayoutPriority) -> CGSize {
    switch direction {
    case .vertical:
      return super.systemLayoutSizeFitting(.init(width: targetSize.width, height: .greatestFiniteMagnitude),
                                           withHorizontalFittingPriority: .required,
                                           verticalFittingPriority: .fittingSizeLevel)
    case .horizontal:
      return super.systemLayoutSizeFitting(.init(width: .greatestFiniteMagnitude, height: targetSize.height),
                                           withHorizontalFittingPriority: .fittingSizeLevel,
                                           verticalFittingPriority: .required)
    }
  }
}

public extension DynamicCollectionCell {
  enum Direction {
    case vertical
    case horizontal
  }
}

#endif
