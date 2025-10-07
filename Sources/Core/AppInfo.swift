//
//  AppInfo.swift
//  PovioKit
//
//  Created by Borut Tomazin on 22/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum AppInfo {
#if os(iOS)
  /// Opens `Settings` app for current app.
  public static func openSettings() {
    URL(string: UIApplication.openSettingsURLString).map { openUrl($0) }
  }
  
  /// Opens `Notifications` section in `Settings` app.
  public static func openNotificationSettings() {
    URL(string: UIApplication.openNotificationSettingsURLString).map { openUrl($0) }
  }
#endif
  
  /// Opens `App Store` deep linking to the app with provided id.
  public static func openAppStore(appId: String) {
    guard let url = URL(string: "itms-apps://apps.apple.com/app/id\(appId)") else { return }
    openUrl(url)
  }
  
  /// Passing the `number` will trigger the system call with "tel://" prefix.
  public static func call(_ number: String) {
    URL(string: "tel://" + number).map { openUrl($0) }
  }
  
  /// Opens given `url` in the default browser, if `canOpenURL` method returns true.
  ///
  /// If `isSafari` param is true, url will be opened in the Safari instead, overriding the default selected browser.
  public static func openUrl(_ url: URL, inSafari: Bool = false) {
    var targetUrl = url
#if os(iOS)
    if inSafari, #available(iOS 17.5, *) {
      targetUrl = URL(string: "x-safari-\(url.absoluteString)")!
    }
    guard UIApplication.shared.canOpenURL(targetUrl) else { return }
    UIApplication.shared.open(targetUrl, options: [:])
#elseif os(macOS)
    if inSafari, let safariUrl = URL(string: "safari://\(url.absoluteString)") {
      targetUrl = safariUrl
    }
    guard NSWorkspace.shared.urlForApplication(toOpen: targetUrl) != nil else { return }
    NSWorkspace.shared.open(targetUrl)
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
