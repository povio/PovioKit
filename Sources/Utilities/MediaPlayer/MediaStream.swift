//
//  MediaStream.swift
//  
//
//  Created by Dejan Skledar on 04/08/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public protocol MediaStream {
  var id: String { get }
  var title: String { get }
  var url: URL { get }
}

public struct GenericAudioStream: MediaStream {
  public let id: String
  public let title: String
  public let url: URL

  public init(id: String, title: String, url: URL) {
    self.id = id
    self.title = title
    self.url = url
  }
}
