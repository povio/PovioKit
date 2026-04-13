//
//  AnimatedImageComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI
import PovioKitSwiftUI

struct AnimatedImageComponent: View {
  var body: some View {
    VStack(spacing: 20) {
      // Basic usage
      VStack {
        Text("Basic Animated Image")
          .font(.headline)
        AnimatedImage(source: .local(fileName: "animation"))
          .squared()
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .overlay {
            RoundedRectangle(cornerRadius: 10)
              .stroke(.gray, lineWidth: 1)
          }
      }
      
      // Customized usage with repeat count and callbacks
      VStack {
        Text("Customized Animated Image")
          .font(.headline)
        AnimatedImage(
          source: .local(fileName: "animation"),
          repeatCount: .finite(count: 3), // Play 3 times then stop
          options: [.transition(.fade(0.3))]
        )
        .onStart {
          print("Animation started!")
        }
        .onEnd {
          print("Animation ended!")
        }
        .squared()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(.blue, lineWidth: 2)
        }
      }
      
      // Manual control example
      VStack {
        Text("Manual Control")
          .font(.headline)
        AnimatedImage(
          source: .local(fileName: "animation"),
          autoplay: false, // Don't start automatically
          options: [.transition(.fade(0.3))]
        )
        .squared()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(.green, lineWidth: 2)
        }
      }
    }
    .padding(20)
  }
}

#Preview {
  AnimatedImageComponent()
}
