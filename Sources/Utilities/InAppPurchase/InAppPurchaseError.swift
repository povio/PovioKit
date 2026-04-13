//
//  InAppPurchaseError.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 19/01/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public enum InAppPurchaseError: Error {
  case missingProductId
  case missingReceipt
  case paymentCancelled
  case paymentPending
  case notPurchased
  case restoreFailed(Error)
  case requestFailed(Error?)
  case validationFailed(Error)
  case verificationFailed
}
