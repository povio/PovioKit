//
//  RetryComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitAsync
import SwiftUI

/// Showcases `retry(policy:)` with exponential backoff + jitter, and
/// `withTimeout(_:)` bounding a long-running operation.
struct RetryComponent: View {
  @State private var attempts: [String] = []
  @State private var isRunning = false
  @State private var summary: String?
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Runs a flaky async operation with retries. The first two attempts throw; the third succeeds.")
          .font(.footnote)
          .foregroundStyle(.secondary)
        
        HStack {
          Button {
            Task { await runRetry() }
          } label: {
            Label("Retry with backoff", systemImage: "arrow.clockwise")
          }
          .buttonStyle(.borderedProminent)
          .disabled(isRunning)
          
          Button {
            Task { await runTimeout() }
          } label: {
            Label("Run with timeout", systemImage: "timer")
          }
          .buttonStyle(.bordered)
          .disabled(isRunning)
        }
        
        if let summary {
          Text(summary)
            .font(.callout.monospaced())
            .foregroundStyle(summary.contains("✓") ? .green : .red)
        }
        
        if !attempts.isEmpty {
          VStack(alignment: .leading, spacing: 6) {
            Text("Log")
              .font(.subheadline.weight(.semibold))
              .foregroundStyle(.secondary)
            ForEach(Array(attempts.enumerated()), id: \.offset) { _, line in
              Text(line)
                .font(.caption.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .padding(12)
          .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .fill(Color.secondary.opacity(0.08))
          )
        }
      }
      .padding(20)
    }
  }
}

private extension RetryComponent {
  enum DemoError: Error { case flaky }
  
  func runRetry() async {
    attempts = []
    summary = nil
    isRunning = true
    defer { isRunning = false }
    
    let counter = AttemptCounter()
    
    do {
      let value: String = try await retry(
        policy: .init(
          maxAttempts: 3,
          initialDelay: .milliseconds(200),
          backoffFactor: 2,
          jitter: .milliseconds(100)
        )
      ) {
        let n = await counter.next()
        let ts = timestamp()
        await MainActor.run { attempts.append("[\(ts)] attempt #\(n)") }
        if n < 3 { throw DemoError.flaky }
        return "ok"
      }
      summary = "✓ succeeded with value: \(value)"
    } catch {
      summary = "✗ failed after retries: \(error)"
    }
  }
  
  func runTimeout() async {
    attempts = []
    summary = nil
    isRunning = true
    defer { isRunning = false }
    
    do {
      _ = try await withTimeout(.milliseconds(500)) {
        try await Task.sleep(for: .seconds(2))
        return "never reached"
      }
      summary = "✓ finished in time"
    } catch AsyncTimeoutError.timedOut {
      summary = "✗ operation timed out after 500ms"
    } catch {
      summary = "✗ \(error)"
    }
  }
  
}

@Sendable private func timestamp() -> String {
  let f = DateFormatter()
  f.dateFormat = "HH:mm:ss.SSS"
  return f.string(from: Date())
}

/// Serialises the incrementing counter so concurrent `retry` attempts stay deterministic.
private actor AttemptCounter {
  private var value = 0
  
  func next() -> Int {
    value += 1
    return value
  }
}

#Preview {
  RetryComponent()
}
