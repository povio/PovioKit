//
//  DeviceShakeViewModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/04/2026.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI
import PovioKitCore

struct DeviceShakeViewModifier: ViewModifier {
  let action: () -> Void
  
  func body(content: Content) -> some View {
    content
      .onAppear()
      .onReceive(NotificationCenter.publisher(for: AppNotification.deviceDidShake)) { _ in
        action()
      }
  }
}

public extension View {
  func onShake(perform action: @escaping () -> Void) -> some View {
    modifier(DeviceShakeViewModifier(action: action))
  }
}
