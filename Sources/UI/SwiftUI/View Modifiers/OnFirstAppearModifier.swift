//
//  OnFirstAppearModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

public struct OnFirstAppearModifier: ViewModifier {
  public typealias VoidHandler = () -> Swift.Void
  @State private var didLoad = false
  let action: VoidHandler?
  
  public func body(content: Content) -> some View {
    content.onAppear {
      guard !didLoad else { return }
      didLoad = true
      action?()
    }
  }
}

public extension View {
  /// Modifier action is executed only once per view lifecycle.
  /// It differs from `onAppear` modifier which is executed everytime wiew appears on the screen.
  func onFirstAppear(perform action: OnFirstAppearModifier.VoidHandler? = nil) -> some View {
    modifier(OnFirstAppearModifier(action: action))
  }
}
