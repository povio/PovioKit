//
//  Logger.swift
//  PovioKit
//
//  Created by Borut Tomazin on 04/29/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import OSLog

public final class Logger: @unchecked Sendable {
  public typealias Parameters = [String: Any]
  public static let shared = Logger()

  private let lock = NSLock()
  private var _logLevel: LogLevel = .none
  private var loggersCache: [String: os.Logger] = [:]

  public var logLevel: LogLevel {
    get { lock.withLock { _logLevel } }
    set { lock.withLock { _logLevel = newValue } }
  }

  private init() {}
}

// MARK: - Log Levels
public extension Logger {
  enum LogLevel: Int, Sendable {
    case none = 0
    case error
    case warn
    case info
    case debug
    case all

    public var label: String {
      switch self {
      case .info:
        return "INFO"
      case .warn:
        return "WARN"
      case .debug:
        return "DEBUG"
      case .error:
        return "ERROR"
      case .none, .all:
        return ""
      }
    }
  }
}

// MARK: - Public Methods
public extension Logger {
  /// Log debug message
  static func debug(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.debug, message: message, params: params, file: file, function: function, line: line)
  }

  /// Log info message
  static func info(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.info, message: message, params: params, file: file, function: function, line: line)
  }

  /// Log warning message
  static func warning(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.warn, message: message, params: params, file: file, function: function, line: line)
  }

  /// Log error message
  static func error(_ message: String, params: Parameters? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    flush(.error, message: message, params: params, file: file, function: function, line: line)
  }
}

// MARK: - Private Methods
private extension Logger {
  static func flush(_ level: LogLevel, message: String, params: Parameters? = nil, file: String, function: String, line: Int) {
    guard shared.logLevel.rawValue >= level.rawValue else { return }

    let fileName = URL(fileURLWithPath: file).lastPathComponent.components(separatedBy: ".").first ?? ""
    let nl = "\n ⮑ "
    var messagePrint = "\(level.label): \(message)"
    if line >= 0 {
      messagePrint += "\(nl)source: \(fileName).\(function):\(line)"
    }
    if let params, !params.isEmpty {
      let groupedParams = params
        .map { "\($0.key): \($0.value)" }
        .sorted()
        .joined(separator: nl)
      messagePrint += "\(nl)\(groupedParams)"
    }

    let logger = shared.logger(forCategory: fileName)
    switch level {
    case .none:
      break
    case .error:
      logger.error("\(messagePrint, privacy: .public)")
    case .warn:
      logger.warning("\(messagePrint, privacy: .public)")
    case .info:
      logger.info("\(messagePrint, privacy: .public)")
    case .debug:
      logger.debug("\(messagePrint, privacy: .public)")
    case .all:
      logger.log("\(messagePrint, privacy: .public)")
    }
  }

  func logger(forCategory category: String) -> os.Logger {
    lock.withLock {
      if let cached = loggersCache[category] {
        return cached
      }
      let subsystem = Bundle.main.bundleIdentifier ?? "povioKit.logger"
      let logger = os.Logger(subsystem: subsystem, category: category)
      loggersCache[category] = logger
      return logger
    }
  }
}
