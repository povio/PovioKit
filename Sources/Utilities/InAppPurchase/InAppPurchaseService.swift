//
//  InAppPurchaseService.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 20/01/2023.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore
import StoreKit

public final class InAppPurchaseService: NSObject {
  public typealias IAPProduct = String
  public typealias IAPReceipt = String
  
  private let productIdentifiers: [IAPProduct]
  private var updateListenerTask: Task<Void, Error>? = nil
  private var availableProducts: [Product] = []
  private var purchasedProducts: [Product] = []
  
  /// Initialize new InAppPurchase with all available products
  /// - Parameter identifiers: Array of ``IAPProduct`` (eg. ["com.test.plan1", "com.test.plan2"])
  public init(identifiers: [IAPProduct]) {
    self.productIdentifiers = identifiers
    super.init()
    updateListenerTask = listenForTransactions()
    
    Task {
      await requestProducts()
      await updatePurchasedProducts()
    }
  }
  
  deinit {
    updateListenerTask?.cancel()
  }
}

// MARK: - Public
extension InAppPurchaseService {
  /// Purchase product with options
  /// - Parameters:
  ///   - product: InAppPurchase product identifier (eg. "com.test.plan") to purchase
  ///   - options: Set of ``PurchaseOption``
  /// - Returns: Result type with completed ``Transaction`` object or ``InAppPurchaseError``
  /// - Important: ``InAppPurchaseError`` cases that this function returns:
  /// * ``InAppPurchaseError.missingProductId``
  /// * ``InAppPurchaseError.paymentCancelled``
  /// * ``InAppPurchaseError.paymentPending``
  /// * ``InAppPurchaseError.requestFailed(error)``
  public func purchase(product: IAPProduct, options: Set<Product.PurchaseOption> = []) async -> Result<Transaction, InAppPurchaseError> {
    guard let product = availableProducts.first(where: { $0.id == product }) else {
      Logger.error("Purchase failed!", params: ["reason": "missing product id"])
      return .failure(InAppPurchaseError.missingProductId)
    }
    do {
      let result = try await product.purchase(options: options)
      switch result {
      case .success(let verification):
        let transaction = try checkVerified(verification)
        await updatePurchasedProducts()
        await transaction.finish()
        return .success(transaction)
      case .userCancelled:
        Logger.error("Purchase failed!", params: ["reason": "User cancelled"])
        return .failure(InAppPurchaseError.paymentCancelled)
      case .pending:
        Logger.error("Purchase pending!")
        return .failure(InAppPurchaseError.paymentPending)
      default:
        Logger.error("Purchase failed!", params: ["reason": "Unknown purchase state"])
        return .failure(InAppPurchaseError.requestFailed(nil))
      }
    } catch {
      Logger.error("Purchase failed!", params: ["error": error.localizedDescription])
      return .failure(InAppPurchaseError.requestFailed(error))
    }
  }
  
  /// Check if product is purchased
  ///
  /// - Parameter product: ``IAPProduct`` to check if purchased
  /// - Returns: Result type with ``Bool`` value if product is purchased or not and ``InAppPurchaseError`` if request fails.
  /// We will return `false` if the transaction is refunded or revoked from family sharing,
  /// and also if the transaction is upgraded to another subscription.
  /// - Important: ``InAppPurchaseError`` cases that this function returns:
  /// * ``InAppPurchaseError.missingProductId``
  /// * ``InAppPurchaseError.notPurchased``
  /// * ``InAppPurchaseError.requestFailed(error)``
  public func isPurchased(_ product: IAPProduct) async -> Result<Bool, InAppPurchaseError> {
    guard availableProducts.first(where: { $0.id == product }) != nil else {
      Logger.error("Check purchase failed!", params: ["reason": "missing product id"])
      return .failure(InAppPurchaseError.missingProductId)
    }
    guard let result = await Transaction.latest(for: product) else {
      return .failure(InAppPurchaseError.notPurchased)
    }
    do {
      let transaction = try checkVerified(result)
      return .success(transaction.revocationDate == nil && !transaction.isUpgraded)
    } catch {
      return .failure(InAppPurchaseError.requestFailed(error))
    }
  }
  
  /// Force restore InAppPurchase
  ///
  /// In regular operations, there’s no need to call ``restorePurchases()``, StoreKit automatically keeps up-to-date transaction information and subscription status available to your app.
  /// - Returns: Result type with .success or ``InAppPurchaseError``
  /// - Important: ``InAppPurchaseError`` cases that this function returns:
  /// * ``InAppPurchaseError.restoreFailed(error)``
  /// - Attention: Call this function only in response to an explicit user action, such as tapping a button.
  /// This call displays a system prompt that asks users to authenticate with their App Store credentials.
  public func restorePurchases() async -> Result<Void, InAppPurchaseError> {
    do {
      try await AppStore.sync()
      return .success(())
    } catch {
      return .failure(InAppPurchaseError.restoreFailed(error))
    }
  }
  
  /// Validate AppStore receipt if available on the phone
  /// - Returns: Result type with receipt ``String`` if available and valid or ``InAppPurchaseError``
  /// - Important: ``InAppPurchaseError`` cases that this function returns:
  /// * ``InAppPurchaseError.missingReceipt``
  /// * ``InAppPurchaseError.validationFailed(error)``
  public func validateReceipt() -> Result<IAPReceipt, InAppPurchaseError> {
    guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
          FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
      Logger.error("Validate receipts failed!", params: ["reason": "missing receipt"])
      return .failure(InAppPurchaseError.missingReceipt)
    }
    do {
      let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
      let receiptString = receiptData.base64EncodedString(options: [])
      return .success(receiptString)
    } catch {
      return .failure(InAppPurchaseError.validationFailed(error))
    }
  }
}

// MARK: - Private
private extension InAppPurchaseService {
  func listenForTransactions() -> Task<Void, Error> {
    return Task.detached {
      for await result in Transaction.updates {
        do {
          let transaction = try self.checkVerified(result)
          await self.updatePurchasedProducts()
          await transaction.finish()
        } catch {
          Logger.error("Transaction failed verification!", params: ["error": error.localizedDescription])
        }
      }
    }
  }
  
  func requestProducts() async {
    guard !productIdentifiers.isEmpty else {
      Logger.error("Get available products failed!", params: ["reason": "no product identifiers"])
      return
    }
    do {
      availableProducts = try await Product.products(for: productIdentifiers)
    } catch {
      Logger.error("Get available products request failed!", params: ["error": error.localizedDescription])
    }
  }
  
  func updatePurchasedProducts() async {
    for await result in Transaction.currentEntitlements {
      do {
        let transaction = try checkVerified(result)
        if let product = availableProducts.first(where: { $0.id == transaction.productID }) {
          purchasedProducts.append(product)
        }
      } catch {
        Logger.error("Update purchased products status failed!", params: ["error": error.localizedDescription])
      }
    }
  }
  
  func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified:
      throw InAppPurchaseError.verificationFailed
    case .verified(let safe):
      return safe
    }
  }
}
