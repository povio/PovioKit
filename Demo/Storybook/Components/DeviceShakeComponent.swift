//
//  DeviceShakeComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import PovioKitCore
import PovioKitSwiftUI
import SwiftUI
import UIKit

/// Demonstrates `.onShake { ... }`.
///
/// `AppNotification.deviceDidShake` is intentionally app-emitted — this view
/// embeds a lightweight `UIViewControllerRepresentable` that becomes the first
/// responder and forwards `motionEnded(.motionShake, ...)` to the notification
/// bus, so the modifier fires inside Storybook without scene-level plumbing.
///
/// In the iOS Simulator: Device > Shake (⌃⌘Z).
struct DeviceShakeComponent: View {
  @State private var shakeCount = 0
  @State private var lastShakeAt: Date?
  
  var body: some View {
    VStack(spacing: 24) {
      ShakeDetector()
        .frame(width: 0, height: 0)
      
      Image(systemName: "iphone.gen3.radiowaves.left.and.right")
        .font(.system(size: 72, weight: .light))
        .foregroundStyle(Color.accentColor)
        .symbolEffect(.pulse, options: .repeating.speed(0.5))
      
      VStack(spacing: 6) {
        Text("Shake the device (⌃⌘Z in Simulator)")
          .font(.callout)
          .foregroundStyle(.secondary)
        Text("Shakes: \(shakeCount)")
          .font(.title.monospacedDigit().weight(.semibold))
        if let lastShakeAt {
          Text("last: \(lastShakeAt.formatted(date: .omitted, time: .standard))")
            .font(.footnote.monospacedDigit())
            .foregroundStyle(.tertiary)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .onShake {
      shakeCount += 1
      lastShakeAt = Date()
    }
  }
}

private struct ShakeDetector: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> ShakeViewController { .init() }
  func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
}

private final class ShakeViewController: UIViewController {
  override var canBecomeFirstResponder: Bool { true }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else {
      super.motionEnded(motion, with: event)
      return
    }
    NotificationCenter.post(AppNotification.deviceDidShake)
  }
}

#Preview {
  DeviceShakeComponent()
}
#endif
