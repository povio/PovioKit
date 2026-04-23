//
//  AudioPlayer.swift
//  PovioKit
//
//  Created by Dejan Skledar on 04/08/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVFoundation
import Foundation

/// An audio-focused playlist wrapper around ``MediaPlayer``.
///
/// ## Design
///
/// `AudioPlayer` *composes* a ``MediaPlayer`` (accessible via
/// ``mediaPlayer``) rather than subclassing it. Prior versions of
/// PovioKit declared `AudioPlayer: MediaPlayer: AVPlayer`; the
/// inheritance chain leaked every `AVPlayer` and `MediaPlayer` API
/// through `AudioPlayer` even though most of that surface is unrelated
/// to playlist navigation. Composition gives callers a narrow,
/// purposeful API and lets `MediaPlayer` evolve independently.
///
/// For fine-grained playback control (seeking, volume, rate, layer
/// hook-up), reach into ``mediaPlayer`` directly.
@MainActor
public final class AudioPlayer {
  /// The wrapped media player. Expose this when you need to drive a
  /// fine-grained operation not covered by ``AudioPlayer``'s navigation
  /// helpers (for example: seeking, rate changes, attaching to an
  /// `AVPlayerLayer`).
  public let mediaPlayer: MediaPlayer

  public private(set) var streams: [any MediaStream] = []
  public private(set) var currentStream: (any MediaStream)?

  /// Legacy alias for ``MediaPlayer/delegate`` preserved for callers
  /// that used the name on the old `AudioPlayer` subclass.
  public var audioDelegate: (any MediaPlayerDelegate)? {
    get { mediaPlayer.delegate }
    set { mediaPlayer.delegate = newValue }
  }

  /// Forwarded convenience accessors.
  public var delegate: (any MediaPlayerDelegate)? {
    get { mediaPlayer.delegate }
    set { mediaPlayer.delegate = newValue }
  }

  /// The current player item, if any. Forwarded from
  /// ``MediaPlayer/currentItem``.
  public var currentItem: AVPlayerItem? { mediaPlayer.currentItem }

  /// The playback state of the underlying player. The setter is
  /// restricted to the module; callers drive state via the domain
  /// methods (``play()``, ``pause()``, ``stop()`` and playlist
  /// navigation).
  public var state: MediaPlayer.PlaybackState {
    get { mediaPlayer.state }
    set { mediaPlayer.state = newValue }
  }

  private var currentStreamIndex: Int? {
    guard let currentStream else { return nil }
    return streams.firstIndex(where: { $0.id == currentStream.id })
  }

  // MARK: - Init

  public init(mediaPlayer: MediaPlayer, streams: [any MediaStream] = []) {
    self.mediaPlayer = mediaPlayer
    self.streams = streams

    if let stream = streams.first {
      currentStream = stream
      selectAudio(stream: stream)
    }
  }

  /// Convenience initializer that builds a fresh ``MediaPlayer`` for
  /// the given streams.
  public convenience init(streams: [any MediaStream] = []) {
    self.init(mediaPlayer: MediaPlayer(), streams: streams)
  }

  // MARK: - Playback

  public func play() { mediaPlayer.play() }
  public func pause() { mediaPlayer.pause() }
  public func stop() { mediaPlayer.stop() }

  // MARK: - Navigation

  /// Switches the player to the given stream without starting playback.
  public func selectAudio(stream: any MediaStream) {
    currentStream = stream
    mediaPlayer.replace(with: AVPlayerItem(url: stream.url))
  }

  /// Advances to the next stream. If the end of the playlist is
  /// reached, stops playback and leaves ``currentStream`` unchanged.
  public func playNext() {
    guard let currentStreamIndex else { return }
    playStreamIfPossible(at: currentStreamIndex + 1)
  }

  /// Goes back to the previous stream. If the start of the playlist is
  /// reached, stops playback and leaves ``currentStream`` unchanged.
  public func playPrevious() {
    guard let currentStreamIndex else { return }
    playStreamIfPossible(at: currentStreamIndex - 1)
  }
}

// MARK: - Private

private extension AudioPlayer {
  func playStreamIfPossible(at index: Int) {
    guard streams.indices.contains(index) else {
      mediaPlayer.stop()
      return
    }

    currentStream = streams[index]
    mediaPlayer.replace(with: AVPlayerItem(url: streams[index].url))
  }
}
