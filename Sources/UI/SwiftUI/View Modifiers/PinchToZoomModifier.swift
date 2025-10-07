//
//  PinchToZoomModifier.swift
//  PovioKit
//
//  Created by Yll Fejziu on 13/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

/// https://stackoverflow.com/a/59878898
public struct PinchToZoomModifier: ViewModifier {
  @StateObject private var viewModel = PinchZoomViewModel()

  public func body(content: Content) -> some View {
    content
      .scaleEffect(viewModel.scale, anchor: viewModel.anchor)
      .offset(viewModel.offset)
      .animation(viewModel.isPinching ? .none : .spring(), value: viewModel.scale)
      .overlay(
        PinchZoom(viewModel: viewModel)
      )
  }
}

public extension View {
  func pinchToZoom() -> some View {
    self.modifier(PinchToZoomModifier())
  }
}

// MARK: - Private
private class PinchZoomViewModel: ObservableObject {
  @Published var scale: CGFloat = 1.0
  @Published var anchor: UnitPoint = .center
  @Published var offset: CGSize = .zero
  @Published var isPinching: Bool = false
  var startLocation: CGPoint = .zero
  var location: CGPoint = .zero
  var numberOfTouches: Int = 0
}

private class PinchZoomView: UIView {
  var viewModel: PinchZoomViewModel

  init(viewModel: PinchZoomViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
    pinchGesture.cancelsTouchesInView = false
    addGestureRecognizer(pinchGesture)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func pinch(gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began:
      viewModel.isPinching = true
      viewModel.startLocation = gesture.location(in: self)
      viewModel.anchor = UnitPoint(x: viewModel.startLocation.x / bounds.width,
                                   y: viewModel.startLocation.y / bounds.height)
      viewModel.numberOfTouches = gesture.numberOfTouches
    case .changed:
      if gesture.numberOfTouches != viewModel.numberOfTouches {
        // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
        let newLocation = gesture.location(in: self)
        let jumpDifference = CGSize(width: newLocation.x - viewModel.location.x,
                                    height: newLocation.y - viewModel.location.y)
        viewModel.startLocation = CGPoint(
          x: viewModel.startLocation.x + jumpDifference.width,
          y: viewModel.startLocation.y + jumpDifference.height
        )
        viewModel.numberOfTouches = gesture.numberOfTouches
      }
      viewModel.scale = gesture.scale
      viewModel.location = gesture.location(in: self)
      viewModel.offset = CGSize(
        width: viewModel.location.x - viewModel.startLocation.x,
        height: viewModel.location.y - viewModel.startLocation.y
      )
    case .ended, .cancelled, .failed:
      viewModel.isPinching = false
      viewModel.scale = 1.0
      viewModel.anchor = .center
      viewModel.offset = .zero
    default:
      break
    }
  }
}

private struct PinchZoom: UIViewRepresentable {
  @ObservedObject var viewModel: PinchZoomViewModel

  func makeUIView(context: Context) -> PinchZoomView {
    .init(viewModel: viewModel)
  }

  func updateUIView(_ uiView: PinchZoomView, context: Context) {
    // state is automatically updated via ViewModel binding
  }
}

#endif
