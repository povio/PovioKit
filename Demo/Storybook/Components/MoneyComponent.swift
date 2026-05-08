//
//  MoneyComponent.swift
//  Storybook
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import PovioKitUtilities
import SwiftUI

/// Showcases the 7.0 `Money` type:
/// typed currency, throwing arithmetic on mixed currencies, scalar
/// multiplication and explicit ordering.
struct MoneyComponent: View {
  @State private var a = Money(amount: 1_299, currency: .usd)
  @State private var b = Money(amount: 799, currency: .usd)
  @State private var c = Money(amount: 1_000, currency: .eur)
  @State private var outcome: Outcome = .neutral("Tap a button below.")
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        card(title: "Prices") {
          row(label: "A", money: a)
          row(label: "B", money: b)
          row(label: "C", money: c)
        }
        
        card(title: "Operations") {
          HStack {
            Button("A + B (same currency)", action: addAB)
            Spacer()
          }
          HStack {
            Button("A + C (mixed currency)", action: addAC)
            Spacer()
          }
          HStack {
            Button("A × 3 (scalar)", action: scaleA)
            Spacer()
          }
          HStack {
            Button("Compare A vs B", action: compareAB)
            Spacer()
          }
        }
        
        card(title: "Result") {
          Text(outcome.message)
            .font(.callout.monospaced())
            .foregroundStyle(outcome.color)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(20)
    }
  }
}

private extension MoneyComponent {
  enum Outcome {
    case success(String)
    case failure(String)
    case neutral(String)
    
    var message: String {
      switch self {
      case .success(let m), .failure(let m), .neutral(let m): m
      }
    }
    
    var color: Color {
      switch self {
      case .success: .green
      case .failure: .red
      case .neutral: .secondary
      }
    }
  }
  
  func addAB() {
    do {
      let sum = try a + b
      outcome = .success("A + B = \(sum.formatted ?? sum.description)")
    } catch {
      outcome = .failure("unexpected: \(error)")
    }
  }
  
  func addAC() {
    do {
      let sum = try a + c
      outcome = .success("A + C = \(sum.formatted ?? sum.description)")
    } catch Money.ArithmeticError.currencyMismatch(let lhs, let rhs) {
      outcome = .failure("threw currencyMismatch(\(lhs.code), \(rhs.code))")
    } catch {
      outcome = .failure("unexpected: \(error)")
    }
  }
  
  func scaleA() {
    let tripled = a * 3
    outcome = .success("A × 3 = \(tripled.formatted ?? tripled.description)")
  }
  
  func compareAB() {
    do {
      let aGreater = try a.isGreaterThan(b)
      outcome = .success("A > B = \(aGreater)  (same-currency ordering)")
    } catch {
      outcome = .failure("\(error)")
    }
  }
  
  @ViewBuilder
  func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
      content()
    }
    .padding(14)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color.secondary.opacity(0.08))
    )
  }
  
  func row(label: String, money: Money) -> some View {
    HStack {
      Text(label)
        .font(.body.weight(.semibold))
      Spacer()
      Text(money.formatted ?? money.description)
        .font(.body.monospacedDigit())
    }
  }
}

#Preview {
  MoneyComponent()
}
