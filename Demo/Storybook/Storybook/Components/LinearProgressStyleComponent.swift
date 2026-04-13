//
//  LinearProgressStyleComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitSwiftUI
import SwiftUI

struct LinearProgressStyleComponent: View {
  var body: some View {
    VStack {
      ProgressView(value: 0.9)
        .progressViewStyle(.style1)
        .frame(height: 6)
      ProgressView(value: 0.6)
        .progressViewStyle(.style2)
        .frame(height: 20)
    }
    .padding()
  }
}

// MARK: - Private Methods
private extension ProgressViewStyle where Self == LinearProgressStyle {
  static var style1: some ProgressViewStyle {
    LinearProgressStyle(
      trackColor: .gray,
      progressColor: .black,
      cornerRadius: 3
    )
  }
  
  static var style2: some ProgressViewStyle {
    LinearProgressStyle(
      trackColor: .gray,
      progressColor: .orange,
      cornerRadius: 12
    )
  }
}

#Preview {
  LinearProgressStyleComponent()
}
