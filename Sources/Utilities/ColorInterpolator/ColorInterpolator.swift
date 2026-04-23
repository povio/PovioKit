//
//  ColorInterpolator.swift
//  PovioKit
//
//  Created by Toni Kocjan on 11/02/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public protocol ColorInterpolator {
  func interpolate(_ startColor: UIColor, with color: UIColor, percentage: CGFloat) throws -> UIColor
  func interpolate(colorPoints: [UIColor], percentage: CGFloat) throws -> UIColor
}

public struct LinearColorInterpolator: ColorInterpolator {
  public init() {}
  
  public func interpolate(_ startColor: UIColor, with color: UIColor, percentage: CGFloat) throws -> UIColor {
    guard
      let startColorComponents = startColor.cgColor.components, startColorComponents.count >= 3,
      let endColorComponents = color.cgColor.components, endColorComponents.count >= 3 else { throw Error.colorComponentsMissing }
    return interpolate(startColorComponents,
                       with: endColorComponents,
                       percentage: percentage)
  }
  
  public func interpolate(colorPoints: [UIColor], percentage: CGFloat) throws -> UIColor {
    guard colorPoints.count >= 2, let firstColor = colorPoints.first, let lastColor = colorPoints.last else { throw Error.colorComponentsMissing }
    let percentage = max(min(1, percentage), 0)
    
    if percentage < 0.01 { return firstColor }
    if percentage > 0.99 { return lastColor }
    
    // Use a strict map so each index in `components` lines up with the same
    // index in `colorPoints`; a previous compactMap version silently shifted
    // indices when a color had no CG components.
    let components: [[CGFloat]] = try colorPoints.map { color in
      guard let c = color.cgColor.components, c.count >= 3 else {
        throw Error.colorComponentsMissing
      }
      return c
    }
    let boxWidth = 1 / CGFloat(colorPoints.count - 1)
    let index = Int(ceil(percentage / boxWidth))
    switch index {
    case 1..<colorPoints.count:
      return interpolate(components[index - 1],
                         with: components[index],
                         percentage: (percentage - CGFloat(index - 1) * boxWidth) / boxWidth)
    default:
      throw Error.indexOutOfBounds
    }
  }
  
  public func interpolate(_ startColor: [CGFloat], with color: [CGFloat], percentage: CGFloat) -> UIColor {
    let percentage = max(min(1, percentage), 0)
    return UIColor(red: startColor[0] * (1 - percentage) + color[0] * percentage,
                   green: startColor[1] * (1 - percentage) + color[1] * percentage,
                   blue: startColor[2] * (1 - percentage) + color[2] * percentage,
                   alpha: 1)
  }
}

public extension LinearColorInterpolator {
  enum Error: Swift.Error {
    case colorComponentsMissing
    case indexOutOfBounds
  }
}

#endif
