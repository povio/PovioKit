//
//  RemoteImageComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 25/02/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Kingfisher
import PovioKitCore
import PovioKitSwiftUI
import SwiftUI

struct RemoteImageComponent: View {
  // Using a stable, high-availability test service. Seeded paths keep the three
  // variants rendering the *same* picture, so the processor effect is obvious.
  private let imageURL = URL(string: "https://picsum.photos/seed/poviokit/800/800")
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        section(title: "Plain") {
          RemoteImage(url: imageURL, animated: true)
            .placeholder { placeholder }
            .onSuccess { _ in Logger.debug("plain: loaded") }
            .onFailure { error in Logger.debug("plain: \(error)") }
            .squared()
        }
        
        section(title: "Rounded corners (Kingfisher processor)") {
          RemoteImage(url: imageURL, animated: true)
            .placeholder { placeholder }
            .processor(RoundCornerImageProcessor(radius: .point(30)))
            .squared()
        }
        
        section(title: "Downsample → HEIC (chained processors)") {
          RemoteImage(url: imageURL, animated: true)
            .placeholder { placeholder }
            .processor(
              DownsamplingImageProcessor(size: .init(width: 120, height: 120))
                |> HEICImageProcessor(compressionQuality: 0.6)
            )
            .squared()
        }
      }
      .padding(20)
    }
  }
  
  @ViewBuilder
  private func section<Content: View>(
    title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
      content()
    }
  }
  
  /// Placeholder with a guaranteed non-zero intrinsic size, so `.squared()`
  /// keeps the slot visible while Kingfisher is fetching / processing.
  private var placeholder: some View {
    ZStack {
      Color.secondary.opacity(0.12)
      ProgressView()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(1, contentMode: .fit)
  }
}

#Preview {
  RemoteImageComponent()
}
