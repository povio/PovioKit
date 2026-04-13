//
//  UICollectionView+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/4/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UICollectionView {
  func register(_ cells: UICollectionViewCell.Type...) {
    cells.forEach { register($0.self, forCellWithReuseIdentifier: $0.identifier) }
  }
  
  func registerSupplementaryView(_ view: UICollectionReusableView.Type, kind: String) {
    register(view.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: view.identifier)
  }
  
  func registerHeaderViews(_ headerViews: UICollectionReusableView.Type...) {
    headerViews.forEach { registerSupplementaryView($0, kind: UICollectionView.elementKindSectionHeader) }
  }
  
  func registerFooterViews(_ footerViews: UICollectionReusableView.Type...) {
    footerViews.forEach { registerSupplementaryView($0, kind: UICollectionView.elementKindSectionFooter) }
  }
  
  func dequeuReusableCell<T: UICollectionViewCell>(at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.identifier)")
    }
    return cell
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(_ cell: T.Type, at indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.identifier)")
    }
    return cell
  }
  
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, at indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("Could not dequeue supplementary view (\(kind)) with identifier: \(T.identifier)")
    }
    return view
  }
  
  /// Dequeue reusable header view
  func dequeueReusableHeaderView<T: UICollectionReusableView>(_ view: T.Type, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      return T()
    }
    return view
  }
  
  /// Dequeue reusable footer view
  func dequeueReusableFooterView<T: UICollectionReusableView>(_ view: T.Type, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      return T()
    }
    return view
  }
  
  /// Returns max available content size excluding content insets
  var maxContentSize: CGSize {
    .init(width: bounds.width - (contentInset.left + contentInset.right),
          height: bounds.height - (contentInset.top + contentInset.bottom))
  }
}

#endif
