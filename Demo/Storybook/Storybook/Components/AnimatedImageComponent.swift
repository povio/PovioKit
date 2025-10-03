//
//  AnimatedImageComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//

import SwiftUI
import PovioKitSwiftUI

struct AnimatedImageComponent: View {
  @State private var animationStarted = false
  @State private var animationEnded = false
  
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
          animated: true,
          autoStartAnimation: true,
          repeatCount: .finite(count: 3), // Play 3 times then stop
          onAnimationStart: {
            animationStarted = true
            print("Animation started!")
          },
          onAnimationEnd: {
            animationEnded = true
            print("Animation ended!")
          }
        )
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
          animated: true,
          autoStartAnimation: false // Don't start automatically
        )
        .squared()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(.green, lineWidth: 2)
        }
      }
      
      // Status indicators
      VStack(spacing: 8) {
        Text("Animation Status:")
          .font(.caption)
        Text("Started: \(animationStarted ? "Yes" : "No")")
          .font(.caption)
          .foregroundColor(animationStarted ? .green : .red)
        Text("Ended: \(animationEnded ? "Yes" : "No")")
          .font(.caption)
          .foregroundColor(animationEnded ? .green : .red)
      }
      .padding(.top)
    }
    .padding(20)
  }
}

#Preview {
  AnimatedImageComponent()
}
