//
//  MeasureSizeModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import SwiftUI

public struct MeasureSizeModifier: ViewModifier {
  public typealias SizeHandler = (CGSize) -> Void
  let onSize: SizeHandler
  let isInitialOnly: Bool
  
  public func body(content: Content) -> some View {
    content
      .background(GeometryReader { geo in
        if isInitialOnly {
          Color.clear
            .onFirstAppear {
              onSize(geo.size)
            }
        } else {
          Color.clear
            .onAppear {
              onSize(geo.size)
            }
            .onChange(of: geo.size) { _, size in
              onSize(size)
            }
        }
      })
  }
}

public extension View {
  /// Measure view size everytime it changes
  func measureSize(_ handler: @escaping MeasureSizeModifier.SizeHandler) -> some View {
    modifier(MeasureSizeModifier(onSize: handler, isInitialOnly: false))
  }
  
  /// Measure view size only for the first time
  func measureInitialSize(_ handler: @escaping MeasureSizeModifier.SizeHandler) -> some View {
    modifier(MeasureSizeModifier(onSize: handler, isInitialOnly: true))
  }
}
