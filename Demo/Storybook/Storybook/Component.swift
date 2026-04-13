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
    }
  }
}
