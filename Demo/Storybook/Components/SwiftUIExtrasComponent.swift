//
//  SwiftUIExtrasComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitSwiftUI
import SwiftUI

/// Bundles a handful of smaller SwiftUI utilities that aren't big enough to
/// warrant their own demo:
///
/// - `onFirstAppear` — runs exactly once per view lifecycle.
/// - `limitInput(text:limit:)` — clamps text-field length.
/// - `pinchToZoom()` — two-finger pinch to scale.
struct SwiftUIExtrasComponent: View {
  @State private var onFirstAppearCount = 0
  @State private var onAppearCount = 0
  @State private var toggle = true
  @State private var username: String = ""
  private let usernameLimit = 12
  
  var body: some View {
    Form {
      Section("onFirstAppear vs onAppear") {
        Toggle("Toggle me to re-appear", isOn: $toggle)
        if toggle {
          Color.clear
            .frame(height: 0)
            .onFirstAppear { onFirstAppearCount += 1 }
            .onAppear { onAppearCount += 1 }
        }
        LabeledContent("onFirstAppear fires") {
          Text("\(onFirstAppearCount)").monospacedDigit()
        }
        LabeledContent("onAppear fires") {
          Text("\(onAppearCount)").monospacedDigit()
        }
      }
      
      Section("limitInput(text:limit:) — max \(usernameLimit)") {
        TextField("Username", text: $username)
          .limitInput(text: $username, limit: usernameLimit)
        LabeledContent("Length") {
          Text("\(username.count) / \(usernameLimit)")
            .font(.body.monospacedDigit())
            .foregroundStyle(username.count == usernameLimit ? .orange : .secondary)
        }
      }
      
      Section("pinchToZoom()") {
        VStack(spacing: 10) {
          Text("Pinch the square with two fingers. Release to spring back.")
            .font(.footnote)
            .foregroundStyle(.secondary)
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
              LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(height: 160)
            .overlay(
              Image(systemName: "hand.pinch.fill")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(.white)
            )
            .pinchToZoom()
        }
      }
    }
  }
}

#Preview {
  SwiftUIExtrasComponent()
}
