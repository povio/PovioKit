//
//  MaterialBlurComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitSwiftUI
import SwiftUI

struct MaterialBlurComponent: View {
  var body: some View {
    RemoteImageComponent()
      .overlay(alignment: .top) {
        VStack {
          Text("First overlay")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(MaterialBlurView(style: .systemUltraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 30)
            .offset(y: 30)
          
          Text("Second overlay")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .blurBackground(style: .systemThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(.horizontal, 30)
            .offset(y: 30)
        }
      }
  }
}

#Preview {
  MaterialBlurComponent()
}
