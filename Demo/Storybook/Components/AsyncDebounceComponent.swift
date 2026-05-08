//
//  AsyncDebounceComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitAsync
import SwiftUI

/// Feeds text-field edits through an `AsyncStream` and observes them via
/// `AsyncDebounceSequence` — the "debounced" output only advances once the
/// user stops typing for `delayBetweenTasks` ms.
struct AsyncDebounceComponent: View {
  @State private var model = ViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Only the debounced line updates — it waits **500ms** of silence before emitting the latest value.")
          .font(.footnote)
          .foregroundStyle(.secondary)
        
        TextField("Type here…", text: $model.text)
          .textFieldStyle(.roundedBorder)
          .onChange(of: model.text) { _, newValue in
            model.emit(newValue)
          }
        
        VStack(alignment: .leading, spacing: 12) {
          row("Raw", value: model.text, color: .secondary)
          row("Debounced", value: model.debounced, color: .accentColor)
        }
        .padding(14)
        .background(
          RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.secondary.opacity(0.08))
        )
      }
      .padding(20)
    }
    .task { await model.start() }
  }
  
  @ViewBuilder
  private func row(_ label: String, value: String, color: Color) -> some View {
    HStack {
      Text(label)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
      Spacer()
      Text(value.isEmpty ? "—" : value)
        .font(.body.monospaced())
        .foregroundStyle(color)
        .lineLimit(1)
        .truncationMode(.tail)
    }
  }
}

@MainActor
@Observable
private final class ViewModel {
  var text: String = ""
  var debounced: String = ""
  
  private var continuation: AsyncStream<String>.Continuation?
  private var stream: AsyncStream<String>?
  
  init() {
    let (stream, continuation) = AsyncStream<String>.makeStream(bufferingPolicy: .bufferingNewest(1))
    self.stream = stream
    self.continuation = continuation
  }
  
  func emit(_ value: String) {
    continuation?.yield(value)
  }
  
  func start() async {
    guard let stream else { return }
    let debouncedStream = stream.debounce(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(500)
    )
    do {
      for try await value in debouncedStream {
        debounced = value
      }
    } catch is CancellationError {
      // View disappeared — no-op.
    } catch {
      debounced = "error: \(error)"
    }
  }
}

#Preview {
  AsyncDebounceComponent()
}
