//
//  ScrollViewWithOffsetComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitSwiftUI
import SwiftUI

/// Parallax header driven by the live offset reported by
/// `ScrollViewWithOffset`.
struct ScrollViewWithOffsetComponent: View {
  private let headerHeight: CGFloat = 220
  @State private var offsetY: CGFloat = 0
  
  var body: some View {
    ScrollViewWithOffset(
      onScroll: { offset in
        offsetY = offset.y
      }
    ) {
      VStack(spacing: 0) {
        header
        content
      }
    }
    .ignoresSafeArea(edges: .top)
  }
  
  private var header: some View {
    let stretch = max(0, offsetY)
    let parallax = min(0, offsetY) * 0.5
    return ZStack {
      LinearGradient(
        colors: [.blue, .purple, .pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      VStack(spacing: 8) {
        Text("ScrollViewWithOffset")
          .font(.title2.weight(.semibold))
          .foregroundStyle(.white)
        Text(String(format: "offset.y = %.1f", offsetY))
          .font(.callout.monospacedDigit())
          .foregroundStyle(.white.opacity(0.85))
      }
    }
    .frame(height: headerHeight + stretch)
    .offset(y: parallax)
    .clipped()
  }
  
  private var content: some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(0..<25, id: \.self) { index in
        HStack {
          Circle()
            .fill(Color.accentColor.opacity(0.2))
            .frame(width: 40, height: 40)
          VStack(alignment: .leading) {
            Text("Row #\(index + 1)")
              .font(.body.weight(.medium))
            Text("Scroll up to stretch, down to parallax.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
        }
        Divider()
      }
    }
    .padding(20)
  }
}

#Preview {
  ScrollViewWithOffsetComponent()
}
