//
//  AppInfo.swift
//  PovioKit
//
//  Created by Borut Tomazin on 22/05/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum AppInfo {
#if os(iOS)
  /// Opens `Settings` app for current app.
  ///
  /// - Returns: `true` when the URL is forwarded to the system opener.
  @discardableResult
  public static func openSettings() -> Bool {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return false }
    return openUrl(settingsUrl)
  }
  
  /// Opens `Notifications` section in `Settings` app.
  ///
  /// - Returns: `true` when the URL is forwarded to the system opener.
  @discardableResult
  public static func openNotificationSettings() -> Bool {
    guard let settingsUrl = URL(string: UIApplication.openNotificationSettingsURLString) else { return false }
    return openUrl(settingsUrl)
  }
#endif
  
  /// Opens App Store deep link for the provided app ID.
  ///
  /// - Returns: `true` when the URL is forwarded to the system opener.
  @discardableResult
  public static func openAppStore(appId: String) -> Bool {
    guard let appStoreUrl = URL(string: "itms-apps://apps.apple.com/app/id\(appId)") else { return false }
    return openUrl(appStoreUrl)
  }
  
  /// Initiates a phone call using a `tel://` URL.
  ///
  /// Characters not supported by `tel://` URLs are removed before opening.
  ///
  /// - Returns: `true` when the sanitized number can be opened.
  @discardableResult
  public static func call(_ number: String) -> Bool {
    let normalizedNumber = number
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .filter { $0.isWholeNumber || $0 == "+" || $0 == "*" || $0 == "#" || $0 == "," }
    guard !normalizedNumber.isEmpty else { return false }
    guard let callUrl = URL(string: "tel://\(normalizedNumber)") else { return false }
    return openUrl(callUrl)
  }
  
  /// Opens the given URL in the default browser when available.
  ///
  /// If `inSafari` is `true`, Safari is preferred when platform support is available
  /// (iOS 17.5+ via the `x-safari-` scheme, macOS by opening the URL with Safari).
  ///
  /// Safe to call from any thread: the system opener is always invoked on the main thread.
  /// `canOpenURL` is intentionally not consulted on iOS, because it returns `false` for any
  /// scheme the app has not declared in `LSApplicationQueriesSchemes` (e.g. `itms-apps`,
  /// `x-safari-https`), even though opening those URLs works.
  ///
  /// - Returns: `true` when the URL is forwarded to the system opener.
  @discardableResult
  public static func openUrl(_ url: URL, inSafari: Bool = false) -> Bool {
#if os(iOS)
    var targetUrl = url
    if inSafari, #available(iOS 17.5, *) {
      guard let safariUrl = URL(string: "x-safari-\(url.absoluteString)") else { return false }
      targetUrl = safariUrl
    }
    let canOpen = AppInfoURLHandlerStore.canOpenUrlHandlerForTesting ?? { _ in true }
    let open = AppInfoURLHandlerStore.openUrlHandlerForTesting ?? { target in
      onMain { UIApplication.shared.open(target, options: [:]) }
    }
    guard canOpen(targetUrl) else { return false }
    open(targetUrl)
    return true
#elseif os(macOS)
    let canOpen = AppInfoURLHandlerStore.canOpenUrlHandlerForTesting ?? { target in
      NSWorkspace.shared.urlForApplication(toOpen: target) != nil
    }
    let open = AppInfoURLHandlerStore.openUrlHandlerForTesting ?? { target in
      onMain {
        if inSafari, let safari = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
          NSWorkspace.shared.open([target], withApplicationAt: safari, configuration: .init())
        } else {
          NSWorkspace.shared.open(target)
        }
      }
    }
    guard canOpen(url) else { return false }
    open(url)
    return true
#else
    return false
#endif
  }
  
  /// Returns the bundle identifier, or `nil` if the `Info.plist` does not
  /// contain `CFBundleIdentifier`.
  public static var bundleId: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
  }
  
  /// Returns the app name, or `nil` if the `Info.plist` does not contain
  /// `CFBundleName`.
  public static var name: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
  }
  
  /// Returns the app build number (for example `84`), or `nil` if the
  /// `Info.plist` does not contain `CFBundleVersion`.
  public static var build: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }
  
  /// Returns the app version (for example `1.9.3`), or `nil` if the
  /// `Info.plist` does not contain `CFBundleShortVersionString`.
  public static var version: String? {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
}

/// Runs `work` on the main actor: synchronously when already on the main thread,
/// otherwise asynchronously on the main queue.
private func onMain(_ work: @escaping @MainActor @Sendable () -> Void) {
  if Thread.isMainThread {
    MainActor.assumeIsolated(work)
  } else {
    DispatchQueue.main.async(execute: work)
  }
}

/// Internal test seam for overriding URL open behavior.
///
/// Tests can inject handlers to avoid external side effects (opening App Store,
/// Phone app, or browser) while still verifying URL-building behavior.
///
/// Access is serialised behind `lock`, which lets the handlers be read from
/// the main thread (production callers) and written from the test thread
/// without data races.
enum AppInfoURLHandlerStore {
  private static let lock = NSLock()
  nonisolated(unsafe) private static var _canOpenUrlHandlerForTesting: (@Sendable (URL) -> Bool)?
  nonisolated(unsafe) private static var _openUrlHandlerForTesting: (@Sendable (URL) -> Void)?
  
  static var canOpenUrlHandlerForTesting: (@Sendable (URL) -> Bool)? {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _canOpenUrlHandlerForTesting
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _canOpenUrlHandlerForTesting = newValue
    }
  }
  
  static var openUrlHandlerForTesting: (@Sendable (URL) -> Void)? {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _openUrlHandlerForTesting
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      _openUrlHandlerForTesting = newValue
    }
  }
}
