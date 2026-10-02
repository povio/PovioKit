//
//  InAppPurchaseService.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 20/01/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore
import StoreKit

internal enum PurchasedProductIDsResolver {
  static func resolve(entitlementProductIDs: [String], availableProductIDs: [String]) -> [String] {
    let availableSet = Set(availableProductIDs)
    var seen = Set<String>()
    var resolved = [String]()

    for id in entitlementProductIDs where availableSet.contains(id) {
      if seen.insert(id).inserted {
        resolved.append(id)
      }
    }

    return resolved
  }
}

public actor InAppPurchaseService {
  public typealias IAPProduct = String
  public typealias IAPReceipt = String

  private let productIdentifiers: [IAPProduct]
  private var updateListenerTask: Task<Void, Error>?

  /// Products available for purchase, populated by ``bootstrap()`` and
  /// kept up-to-date as transactions arrive on `Transaction.updates`.
  ///
  /// Empty until the initial product fetch completes; call
  /// ``bootstrap()`` and `await` it to take a synchronous dependency on
  /// this list.
  public private(set) var availableProducts: [Product] = []

  /// Products that the current user is currently entitled to. Refreshed
  /// after every successful ``purchase(product:options:)`` and on each
  /// transaction update from `Transaction.updates`.
  public private(set) var purchasedProducts: [Product] = []

  /// Called for every verified transaction delivered outside of
  /// ``purchase(product:options:)`` — e.g. approved Ask-to-Buy requests,
  /// purchases made on another device, renewals and refunds — right before it
  /// is finished. Use it to deliver consumables and unlock content.
  private var transactionUpdateHandler: (@Sendable (Transaction) async -> Void)?

  /// Initialize new InAppPurchase with all available products.
  ///
  /// The service begins listening for transaction updates and loads products
  /// in the background as soon as it is constructed. Call ``bootstrap()``
  /// explicitly to `await` that initial load before taking a dependency on
  /// ``availableProducts``.
  /// - Parameter identifiers: Array of ``IAPProduct`` (eg. ["com.test.plan1", "com.test.plan2"])
  public init(identifiers: [IAPProduct]) {
    self.productIdentifiers = identifiers
    Task { [weak self] in
      await self?.bootstrap()
    }
  }

  deinit {
    updateListenerTask?.cancel()
  }
}

// MARK: - Public
extension InAppPurchaseService {
  /// Awaitable initialization that finishes once products have been fetched
  /// and existing entitlements have been resolved.
  public func bootstrap() async {
    if updateListenerTask == nil {
      updateListenerTask = listenForTransactions()
    }
    await requestProducts()
    await updatePurchasedProducts()
  }

  /// Registers a handler for transactions arriving on `Transaction.updates`
  /// (Ask-to-Buy approvals, other devices, renewals, refunds). The handler runs
  /// before the transaction is finished, so consumables can be delivered safely.
  public func setTransactionUpdateHandler(_ handler: (@Sendable (Transaction) async -> Void)?) {
    transactionUpdateHandler = handler
  }

  /// Purchase product with options.
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
    if availableProducts.isEmpty {
      // The initial fetch may have failed (offline launch); retry lazily.
      await requestProducts()
    }
    guard let product = availableProducts.first(where: { $0.id == product }) else {
      Logger.warning("Purchase failed.", params: ["reason": "missing product id"])
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
        Logger.info("Purchase cancelled by user.")
        return .failure(InAppPurchaseError.paymentCancelled)
      case .pending:
        Logger.info("Purchase pending.")
        return .failure(InAppPurchaseError.paymentPending)
      @unknown default:
        Logger.error("Unknown purchase state.")
        return .failure(InAppPurchaseError.requestFailed(nil))
      }
    } catch {
      Logger.error("Purchase failed.", params: ["error": error.localizedDescription])
      return .failure(InAppPurchaseError.requestFailed(error))
    }
  }

  /// Check if product is purchased.
  /// - Parameter product: ``IAPProduct`` to check if purchased
  /// - Returns: Result type with ``Bool`` value if product is purchased or not and ``InAppPurchaseError`` if request fails.
  public func isPurchased(_ product: IAPProduct) async -> Result<Bool, InAppPurchaseError> {
    // Check against the configured identifiers rather than `availableProducts`,
    // so entitlement checks don't depend on the network product fetch.
    guard productIdentifiers.contains(product) else {
      Logger.warning("Check purchase failed.", params: ["reason": "missing product id"])
      return .failure(InAppPurchaseError.missingProductId)
    }
    // `currentEntitlement(for:)` excludes expired subscriptions, unlike `latest(for:)`.
    guard let result = await Transaction.currentEntitlement(for: product) else {
      return .failure(InAppPurchaseError.notPurchased)
    }
    do {
      let transaction = try checkVerified(result)
      return .success(transaction.revocationDate == nil && !transaction.isUpgraded)
    } catch {
      return .failure(InAppPurchaseError.requestFailed(error))
    }
  }

  /// Force restore InAppPurchase.
  public func restorePurchases() async -> Result<Void, InAppPurchaseError> {
    do {
      try await AppStore.sync()
      return .success(())
    } catch {
      return .failure(InAppPurchaseError.restoreFailed(error))
    }
  }

  /// Validate AppStore receipt if available on the phone.
  public nonisolated func validateReceipt() -> Result<IAPReceipt, InAppPurchaseError> {
    guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
          FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
      Logger.warning("Validate receipts failed.", params: ["reason": "missing receipt"])
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
    Task { [weak self] in
      for await result in Transaction.updates {
        guard let self else { return }
        do {
          let transaction = try self.checkVerified(result)
          await self.updatePurchasedProducts()
          let handler = await self.transactionUpdateHandler
          await handler?(transaction)
          await transaction.finish()
        } catch {
          Logger.error("Transaction failed verification.", params: ["error": error.localizedDescription])
        }
      }
    }
  }

  func requestProducts() async {
    guard !productIdentifiers.isEmpty else {
      Logger.warning("Get available products skipped.", params: ["reason": "no product identifiers"])
      return
    }
    do {
      availableProducts = try await Product.products(for: productIdentifiers)
    } catch {
      Logger.error("Get available products request failed.", params: ["error": error.localizedDescription])
    }
  }

  func updatePurchasedProducts() async {
    var newlyPurchased: [Product] = []
    for await result in Transaction.currentEntitlements {
      do {
        let transaction = try checkVerified(result)
        if let product = availableProducts.first(where: { $0.id == transaction.productID }),
           !newlyPurchased.contains(where: { $0.id == product.id }) {
          newlyPurchased.append(product)
        }
      } catch {
        Logger.error("Update purchased products status failed.", params: ["error": error.localizedDescription])
      }
    }
    purchasedProducts = newlyPurchased
  }

  nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    switch result {
    case .unverified:
      throw InAppPurchaseError.verificationFailed
    case .verified(let safe):
      return safe
    }
  }
}
