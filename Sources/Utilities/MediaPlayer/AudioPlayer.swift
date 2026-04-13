//
//  AudioPlayer.swift
//  
//
//  Created by Dejan Skledar on 04/08/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public class AudioPlayer: MediaPlayer {

  // MARK: - Public properties -

  public private(set) var streams: [MediaStream] = []
  public private(set) var currentStream: MediaStream?

  public weak var audioDelegate: MediaPlayerDelegate?

  // MARK: - Private properties -

  private var currentStreamIndex: Int? {
    streams.firstIndex(where: { $0.id == currentStream?.id })
  }

  // MARK: - Init -

  public convenience init(streams: [MediaStream]) {
    self.init()
    self.streams = streams

    if let stream = streams.first {
      currentStream = stream
      selectAudio(stream: stream)
    }
  }

  // MARK: - Public methods -

  public func selectAudio(stream: MediaStream) {
    currentStream = stream
    replaceCurrentItem(with: .init(url: stream.url))
  }

  public func playNext() {
    guard let currentStreamIndex else { return }
    playStreamIfPossible(at: currentStreamIndex + 1)
  }

  public func playPrevious() {
    guard let currentStreamIndex else { return }
    playStreamIfPossible(at: currentStreamIndex - 1)
  }

  // MARK: - Private methods -

  private func playStreamIfPossible(at index: Int) {
    guard streams.indices.contains(index) else {
      stop()
      return
    }

    currentStream = streams[index]
    replaceCurrentItem(with: .init(url: streams[index].url))
  }
}
