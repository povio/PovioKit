//
//  DynamicCollectionCellTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUIKit

@MainActor
final class DynamicCollectionCellTests: XCTestCase {
  func test_defaultDirection_isVertical() {
    let cell = DynamicCollectionCell()
    
    // `Direction` has no explicit Equatable conformance so we pattern match.
    if case .vertical = cell.direction {
      // OK
    } else {
      XCTFail("Expected default direction to be .vertical, got \(cell.direction)")
    }
  }
  
  func test_verticalDirection_requestedWidthWins_heightTracksContent() {
    let cell = makeCell(direction: .vertical, contentSize: .init(width: 120, height: 40))
    
    let target = CGSize(width: 200, height: 10)
    let fitting = cell.systemLayoutSizeFitting(
      target,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel
    )
    
    // Override pins horizontal to .required, so we always get the requested width.
    XCTAssertEqual(fitting.width, 200, accuracy: 0.5)
    // Height compresses to content (40) even though we passed a tiny target height.
    XCTAssertEqual(fitting.height, 40, accuracy: 0.5)
  }
  
  func test_horizontalDirection_requestedHeightWins_widthTracksContent() {
    let cell = makeCell(direction: .horizontal, contentSize: .init(width: 120, height: 40))
    
    let target = CGSize(width: 10, height: 80)
    let fitting = cell.systemLayoutSizeFitting(
      target,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel
    )
    
    // Override pins vertical to .required, so we always get the requested height.
    XCTAssertEqual(fitting.height, 80, accuracy: 0.5)
    // Width compresses to content (120) even though we passed a tiny target width.
    XCTAssertEqual(fitting.width, 120, accuracy: 0.5)
  }
}

private extension DynamicCollectionCellTests {
  /// Builds a cell whose `contentView` is pinned to the cell's edges and contains
  /// a subview with a fixed intrinsic size, so autolayout has a deterministic
  /// fitting size to compress / expand to.
  func makeCell(direction: DynamicCollectionCell.Direction, contentSize: CGSize) -> DynamicCollectionCell {
    let cell = DynamicCollectionCell()
    cell.direction = direction
    cell.contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      cell.contentView.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
      cell.contentView.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
      cell.contentView.topAnchor.constraint(equalTo: cell.topAnchor),
      cell.contentView.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
    ])
    
    let content = UIView()
    content.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(content)
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
      content.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
      content.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
      content.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
      content.widthAnchor.constraint(equalToConstant: contentSize.width),
      content.heightAnchor.constraint(equalToConstant: contentSize.height)
    ])
    return cell
  }
}

#endif
