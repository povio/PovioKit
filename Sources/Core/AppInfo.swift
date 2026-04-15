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
  
  /// Opens `App Store` deep linking to the app with provided id.
  ///
  /// - Returns: `true` when the URL is forwarded to the system opener.
  @discardableResult
  public static func openAppStore(appId: String) -> Bool {
    guard let appStoreUrl = URL(string: "itms-apps://apps.apple.com/app/id\(appId)") else { return false }
    return openUrl(appStoreUrl)
  }
  
  /// Passing the `number` will trigger the system call with "tel://" prefix.
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
  
  /// Opens given `url` in the default browser, if `canOpenURL` method returns true.
  ///
  /// If `isSafari` param is true, url will be opened in the Safari instead, overriding the default selected browser.
  ///
  /// - Returns: `true` when the URL passes `canOpenURL` and is forwarded for opening.
  @discardableResult
  public static func openUrl(_ url: URL, inSafari: Bool = false) -> Bool {
    var targetUrl = url
#if os(iOS)
    if inSafari, #available(iOS 17.5, *) {
      guard let safariUrl = URL(string: "x-safari-\(url.absoluteString)") else { return false }
      targetUrl = safariUrl
    }
    let canOpen = AppInfoURLHandlerStore.canOpenUrlHandlerForTesting ?? { target in
      UIApplication.shared.canOpenURL(target)
    }
    let open = AppInfoURLHandlerStore.openUrlHandlerForTesting ?? { target in
      UIApplication.shared.open(target, options: [:])
    }
    guard canOpen(targetUrl) else { return false }
    open(targetUrl)
    return true
#elseif os(macOS)
    if inSafari, let safariUrl = URL(string: "safari://\(url.absoluteString)") {
      targetUrl = safariUrl
    }
    let canOpen = AppInfoURLHandlerStore.canOpenUrlHandlerForTesting ?? { target in
      NSWorkspace.shared.urlForApplication(toOpen: target) != nil
    }
    let open = AppInfoURLHandlerStore.openUrlHandlerForTesting ?? { target in
      NSWorkspace.shared.open(target)
    }
    guard canOpen(targetUrl) else { return false }
    open(targetUrl)
    return true
#else
    return false
#endif
  }
  
  /// Returns bundle id
  public static var bundleId: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "/"
  }
  
  /// Returns app name
  public static var name: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "/"
  }
  
  /// Returns App Store build, e.g. `84`
  public static var build: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "/"
  }
  
  /// Returns App Store app version, e.g. `1.9.3`
  public static var version: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "/"
  }
}

/// Internal test seam for overriding URL open behavior.
///
/// Tests can inject handlers to avoid external side effects (opening App Store,
/// Phone app, or browser) while still verifying URL-building behavior.
enum AppInfoURLHandlerStore {
  static var canOpenUrlHandlerForTesting: ((URL) -> Bool)?
  static var openUrlHandlerForTesting: ((URL) -> Void)?
}
