//
//  StartupProcess.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// An abstraction for a predefined set of functionality, aimed to be ran once, at app startup.
public protocol StartupProcess: AnyObject {
  func run(completion: @escaping (Bool) -> Void)
}

extension StartupProcess {
  public var id: String {
    String(ObjectIdentifier(self).hashValue)
  }
}
