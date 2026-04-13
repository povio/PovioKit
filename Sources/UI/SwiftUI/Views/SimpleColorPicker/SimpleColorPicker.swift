//
//  SimpleColorPicker.swift
//  PovioKit
//
//  Created by Borut Tomazin on 15/08/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(macOS)
import SwiftUI
import Combine

/// SwiftUI wrapper for NSColorWell, allowing the selection of colors with a customizable size.
public struct SimpleColorPicker: NSViewRepresentable {
  @Binding var selection: Color
  var size: CGSize?
  
  public init(selection: Binding<Color>, size: CGSize? = nil) {
    self._selection = selection
    self.size = size
  }
  
  public func makeNSView(context: Context) -> NSColorWell {
    let colorWell: NSColorWell
    if #available(macOS 13.0, *) {
      colorWell = NSColorWell(style: .minimal)
    } else {
      colorWell = NSColorWell()
    }
    colorWell.color = NSColor(selection)
    
    context.coordinator.startObservingColorChange(of: colorWell)
    
    // override the size
    if let size {
      colorWell.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        colorWell.widthAnchor.constraint(equalToConstant: size.width),
        colorWell.heightAnchor.constraint(equalToConstant: size.height)
      ])
    }
    
    return colorWell
  }
  
  public func updateNSView(_ nsView: NSColorWell, context: Context) {
    context.coordinator.colorDidChange = {
      selection = Color(nsColor: $0)
    }
    
    // update the size
    if let size {
      if let widthConstraint = nsView.constraints.first(where: { $0.firstAttribute == .width }) {
        widthConstraint.constant = size.width
      }
      if let heightConstraint = nsView.constraints.first(where: { $0.firstAttribute == .height }) {
        heightConstraint.constant = size.height
      }
    }
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  @MainActor
  public class Coordinator: NSObject {
    var colorDidChange: ((NSColor) -> Void)?
    
    private var cancellable: AnyCancellable?
    
    func startObservingColorChange(of colorWell: NSColorWell) {
      cancellable = colorWell.publisher(for: \.color).sink { [weak self] in
        self?.colorDidChange?($0)
      }
    }
  }
}
#endif
