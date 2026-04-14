//
//  NotificationCenter+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 14/04/2026.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// A type that can be represented as `Notification.Name`.
public protocol PovioNotificationRepresentable {
  var name: Notification.Name { get }
}

/// Unified app notification entrypoint.
public enum AppNotification: Hashable, PovioNotificationRepresentable {
#if canImport(UIKit)
  case onAppResume
  case onAppPause
  case onScreenshot
  case keyboardWillShow
  case keyboardWillHide
#endif
  case deviceDidShake
  case named(Notification.Name)
  
  /// Creates a custom notification from a raw notification name.
  public static func named(_ rawName: String) -> Self {
    .named(Notification.Name(rawName))
  }
  
  public var name: Notification.Name {
    switch self {
#if canImport(UIKit)
    case .onAppResume:
      return UIApplication.willEnterForegroundNotification
    case .onAppPause:
      return UIApplication.didEnterBackgroundNotification
    case .onScreenshot:
      return UIApplication.userDidTakeScreenshotNotification
    case .keyboardWillShow:
      return UIResponder.keyboardWillShowNotification
    case .keyboardWillHide:
      return UIResponder.keyboardWillHideNotification
#endif
    case .deviceDidShake:
      return Notification.Name("com.poviokit.notification.deviceDidShake")
    case let .named(name):
      return name
    }
  }
}

extension Notification.Name: PovioNotificationRepresentable {
  public var name: Notification.Name { self }
}

public extension NotificationCenter {
  static func post<N: PovioNotificationRepresentable>(_ notification: N, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
    NotificationCenter.default.post(name: notification.name, object: object, userInfo: userInfo)
  }
  
  @discardableResult
  static func observe<N: PovioNotificationRepresentable>(
    _ notification: N,
    object: Any? = nil,
    queue: OperationQueue? = .main,
    callback: @escaping (Notification) -> Void
  ) -> NSObjectProtocol {
    NotificationCenter.default.addObserver(
      forName: notification.name,
      object: object,
      queue: queue,
      using: callback
    )
  }
  
  @discardableResult
  static func observe<N: PovioNotificationRepresentable>(
    _ notifications: [N],
    object: Any? = nil,
    queue: OperationQueue? = .main,
    callback: @escaping (N, Notification) -> Void
  ) -> [NSObjectProtocol] {
    notifications.map { notification in
      NotificationCenter.default.addObserver(
        forName: notification.name,
        object: object,
        queue: queue
      ) { observedNotification in
        callback(notification, observedNotification)
      }
    }
  }
  
  static func publisher<N: PovioNotificationRepresentable>(for notification: N, object: AnyObject? = nil) -> NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: notification.name, object: object)
  }
  
  static func remove<N: PovioNotificationRepresentable>(_ observer: Any, for notification: N, object: Any? = nil) {
    NotificationCenter.default.removeObserver(observer, name: notification.name, object: object)
  }
  
  static func remove(_ observer: Any) {
    NotificationCenter.default.removeObserver(observer)
  }
}
