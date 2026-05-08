//
//  Component.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

enum Component: CaseIterable {
  case photoPicker
  case animatedImage
  case remoteImage
  case materialBlur
  case linearProgressStyle
  case scrollViewWithOffset
  case deviceShake
  case swiftUIExtras
  case money
  case retry
  case asyncDebounce
}

extension Component {
  var name: String {
    switch self {
    case .photoPicker:
      return "Photo Picker"
    case .animatedImage:
      return "Animated Image / GIF"
    case .remoteImage:
      return "Remote Image"
    case .materialBlur:
      return "Material Blur"
    case .linearProgressStyle:
      return "Linear Progress Style"
    case .scrollViewWithOffset:
      return "Scroll View with Offset"
    case .deviceShake:
      return "Device Shake"
    case .swiftUIExtras:
      return "SwiftUI Extras"
    case .money:
      return "Money"
    case .retry:
      return "Retry & Timeout"
    case .asyncDebounce:
      return "Async Debounce"
    }
  }
}
