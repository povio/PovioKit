//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/06/2022.
//  Copyright © 2025 Povio Labs. All rights reserved.
//

import Foundation

public enum Currency: Codable, Equatable, Hashable, CaseIterable {
  /// U.S. Dollar (USD)
  case usd
  /// European Euro (EUR)
  case eur
  /// Canadian Dollar (CAD)
  case cad
  /// Chinese Yuan Renminbi (CNY)
  case cny
  /// Japanese Yen (JPY)
  case jpy
  /// British Pound (GBP)
  case gbp
  /// Swiss Franc (CHF)
  case chf
}

public extension Currency {
  var code: String {
    switch self {
    case .usd:
      return "USD"
    case .eur:
      return "EUR"
    case .cad:
      return "CAD"
    case .cny:
      return "CNY"
    case .jpy:
      return "JPY"
    case .gbp:
      return "GBP"
    case .chf:
      return "CHF"
    }
  }
  
  var symbol: String {
    switch self {
    case .usd:
      return "$"
    case .eur:
      return "€"
    case .cad:
      return "$"
    case .cny:
      return "¥"
    case .jpy:
      return "¥"
    case .gbp:
      return "£"
    case .chf:
      return "Fr"
    }
  }
}
