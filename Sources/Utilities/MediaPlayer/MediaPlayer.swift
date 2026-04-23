//
//  MediaPlayer.swift
//  PovioKit
//
//  Created by Toni Kocjan on 29/10/2021.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import AVKit
import PovioKitCore

/// Delegate callbacks for ``MediaPlayer``.
///
/// All methods are dispatched on the main actor because `AVPlayer`
/// mutation, `AVPlayerLayer` rendering, and `UIKit`/`AppKit` interop are
/// conventionally performed from the main thread.
@MainActor
public protocol MediaPlayerDelegate: AnyObject {
  func mediaPlayer(didBeginPlayback player: MediaPlayer)
  func mediaPlayer(didEndPlayback player: MediaPlayer)
  func mediaPlayer(didPausePlayback player: MediaPlayer)
  func mediaPlayer(didBeginReplay player: MediaPlayer)
  func mediaPlayer(didBeginBuffering player: MediaPlayer)
  func mediaPlayer(didEndBuffering player: MediaPlayer)
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double)
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float)

  func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Error)
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState)
}

public extension MediaPlayerDelegate {
  func mediaPlayer(didBeginPlayback player: MediaPlayer) {}
  func mediaPlayer(didEndPlayback player: MediaPlayer) {}
  func mediaPlayer(didPausePlayback player: MediaPlayer) {}
  func mediaPlayer(didBeginReplay player: MediaPlayer) {}
  func mediaPlayer(didBeginBuffering player: MediaPlayer) {}
  func mediaPlayer(didEndBuffering player: MediaPlayer) {}
  func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) {}
  func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Error) {}
  func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState) {}
  func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float) {}
}

/// A domain-focused wrapper around `AVPlayer`.
///
/// ## Design
///
/// `MediaPlayer` *composes* an `AVPlayer` rather than subclassing one.
/// The underlying player is exposed via ``avPlayer`` so callers can hand
/// it to an `AVPlayerLayer` / `AVPlayerViewController`; everything else
/// goes through the domain methods below, which keeps the wrapper's
/// invariants (playback interval, state machine, delegate callbacks)
/// intact.
///
/// Prior versions of PovioKit declared `MediaPlayer: AVPlayer`. That
/// inheritance relationship leaked the whole `AVPlayer` API surface and
/// let callers bypass the wrapper's state tracking by calling e.g.
/// `player.rate = 0` directly, which silently desynced ``state`` from
/// reality.
///
/// ## Concurrency
///
/// The class is `@MainActor`-isolated because `AVPlayer` control, KVO
/// callbacks, and periodic time observer callbacks are best performed on
/// the main thread. Delegate methods are therefore also main-actor
/// isolated.
@MainActor
public final class MediaPlayer {
  /// The underlying `AVPlayer`.
  ///
  /// Exposed so callers can attach it to an `AVPlayerLayer` or
  /// `AVPlayerViewController`. Mutating this player directly (e.g.
  /// calling `avPlayer.play()` instead of ``play()``) bypasses the
  /// wrapper's state machine — prefer the domain methods on
  /// `MediaPlayer` whenever possible.
  public let avPlayer: AVPlayer

  public private(set) var playbackInterval: (startAt: Double, endAt: Double)

  /// A Boolean value that determines whether the media player should
  /// loop playback when it reaches the end of the media (or the end of
  /// the configured ``playbackInterval``).
  public var allowsLooping = false

  /// Interval in milliseconds at which the player emits progress
  /// callbacks. Default is `500`. Setting this replaces the underlying
  /// periodic time observer.
  public var timeObservingMilliseconds: Int = 500 {
    didSet {
      guard timeObservingMilliseconds != oldValue else { return }
      removePeriodicTimeObserver()
      setupPeriodicTimeObserver()
    }
  }

  /// The total duration of the current media item in seconds. Returns
  /// `0` if the duration is unknown or the current item is missing.
  public var duration: Double {
    guard let duration = avPlayer.currentItem?.duration,
          duration.isValid,
          !duration.seconds.isNaN
    else { return 0 }
    return duration.seconds
  }

  /// A Boolean value indicating whether the media player is currently
  /// playing (i.e. `rate > 0`).
  public var isPlaying: Bool { avPlayer.rate > 0.0 }

  /// The current playback time of the media player in seconds.
  public var currentTimeSeconds: Double {
    Double(CMTimeGetSeconds(avPlayer.currentTime()))
  }

  /// The currently-loaded `AVPlayerItem`, if any. Convenience for
  /// `avPlayer.currentItem`.
  public var currentItem: AVPlayerItem? { avPlayer.currentItem }

  /// The state of the media player. Setting is restricted to the module
  /// so callers can't inject arbitrary state transitions; internal
  /// drivers (e.g. the player-item KVO observer, notification handlers)
  /// and tests with `@testable import` still have write access.
  public internal(set) var state: PlaybackState = .preparing {
    didSet { onStateUpdate() }
  }

  public weak var delegate: (any MediaPlayerDelegate)?

  /// Flipped to `true` once the current item reports `.readyToPlay`.
  private var canPlay: Bool = false
  /// Set when `play()` is called before the item is ready; consulted
  /// when the item finally reaches `.readyToPlay`.
  private var playWhenReady: Bool = false
  private var playerItemObserver: NSKeyValueObservation?
  private var periodicTimeObserver: Any?
  private var endOfPlaybackObserver: NSObjectProtocol?
  private weak var observedPlayerItem: AVPlayerItem?

  // MARK: - Init

  public init(playerItem: AVPlayerItem? = nil) {
    self.avPlayer = AVPlayer(playerItem: playerItem)
    self.playbackInterval = (0, 0)
    // `duration` depends on `avPlayer`, which is now initialized — recompute.
    self.playbackInterval = (0, duration)
    setupPlayerItemObserver()
  }

  public convenience init(url: URL) {
    self.init(playerItem: AVPlayerItem(url: url))
  }

  public convenience init(asset: AVURLAsset) {
    self.init(playerItem: AVPlayerItem(asset: asset))
  }

  // MARK: - Playback

  /// Starts playing the current item. If the item is not yet ready,
  /// defers playback until `.readyToPlay` is reported.
  public func play() {
    guard canPlay else {
      setupPlayerItemObserver()
      playWhenReady = true
      return
    }

    playWhenReady = false
    setupPlayerItemObserver()
    avPlayer.play()
    state = .playing
  }

  /// Pauses playback and updates ``state`` to ``PlaybackState/paused``.
  public func pause() {
    avPlayer.pause()
    state = .paused
  }

  /// Stops playback, seeks back to the start of ``playbackInterval``,
  /// and tears down observers.
  public func stop() {
    avPlayer.pause()
    setPlaybackPosition(to: playbackInterval.startAt)
    removePeriodicTimeObserver()
    removePlayerItemObserver()
    canPlay = false
    state = .stopped
  }

  /// Starts playing from `fromTime` up to the end of the current item.
  public func play(from fromTime: Double) {
    guard fromTime < duration else {
      Logger.error("`fromTime` should be less than total duration")
      return
    }
    playbackInterval = (fromTime, duration)
    jump(to: fromTime)
    play()
  }

  /// Starts playing the range `[fromTime, toTime]`.
  public func play(from fromTime: Double, to toTime: Double) {
    guard fromTime < toTime else {
      Logger.error("`fromTime` should be less than `toTime`")
      return
    }
    playbackInterval = (fromTime, toTime)
    setPlaybackPosition(to: fromTime)
    play()
  }

  /// Seeks to the given time without changing playback state.
  public func jump(to time: Double) {
    setPlaybackPosition(to: time)
  }

  /// Seeks forward by `seconds`, clamped to the end of
  /// ``playbackInterval``.
  public func seekForward(seconds: Double) {
    setPlaybackPosition(to: min(currentTimeSeconds + seconds, playbackInterval.endAt))
  }

  /// Seeks backward by `seconds`, clamped to the start of
  /// ``playbackInterval``.
  public func seekBackward(seconds: Double) {
    setPlaybackPosition(to: max(currentTimeSeconds - seconds, playbackInterval.startAt))
  }

  // MARK: - Items

  /// Replaces the current `AVPlayerItem` and resets the playback
  /// interval to cover the new item's full duration.
  ///
  /// Pass `nil` to clear the player.
  public func replace(with item: AVPlayerItem?) {
    avPlayer.replaceCurrentItem(with: item)
    playbackInterval = (0, duration)
    setupPlayerItemObserver()
  }

  /// Updates the playback interval. If the current playback position
  /// falls outside the new range it is clamped into it.
  public func updatePlaybackInterval(startAt: Double, endAt: Double) {
    guard startAt < endAt else {
      Logger.error("`startAt` should be less than `endAt`")
      return
    }
    playbackInterval = (startAt, endAt)
    setupPeriodicTimeObserver()

    if currentTimeSeconds < startAt || currentTimeSeconds > endAt {
      setPlaybackPosition(to: max(startAt, min(endAt, currentTimeSeconds)))
    }
  }
}

// MARK: - Private

private extension MediaPlayer {
  func setupPlayerItemObserver() {
    // Block-based NotificationCenter observers don't require `self` to
    // be an NSObject, so we can drop the old `@objc` selector and keep
    // this class as a plain Swift class.
    if let endOfPlaybackObserver {
      NotificationCenter.default.removeObserver(endOfPlaybackObserver)
      self.endOfPlaybackObserver = nil
    }
    endOfPlaybackObserver = NotificationCenter.default.addObserver(
      forName: AVPlayerItem.didPlayToEndTimeNotification,
      object: avPlayer.currentItem,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        guard let self else { return }
        self.removePeriodicTimeObserver()
        if let observer = self.endOfPlaybackObserver {
          NotificationCenter.default.removeObserver(observer)
          self.endOfPlaybackObserver = nil
        }
        self.state = .ended
      }
    }

    if playerItemObserver != nil, observedPlayerItem === avPlayer.currentItem {
      setupPeriodicTimeObserver()
      return
    }

    observedPlayerItem = avPlayer.currentItem
    removePeriodicTimeObserver()
    playerItemObserver?.invalidate()
    playerItemObserver = avPlayer.currentItem?.observe(\.status, options: [.new, .old, .initial]) { [weak self] playerItem, _ in
      // KVO callbacks are delivered on the thread that mutates the
      // observed property; hop to main so we can touch the MainActor
      // state without violating isolation.
      Task { @MainActor [weak self] in
        guard let self else { return }
        switch playerItem.status {
        case .readyToPlay:
          self.canPlay = true
          self.state = .readyToPlay
          self.setupPeriodicTimeObserver()
          if self.playWhenReady {
            self.play()
          }
        case .unknown:
          self.canPlay = false
          self.state = .failed(error: Error.undefinedState)
        case .failed:
          self.canPlay = false
          self.state = .failed(error: playerItem.error ?? Error.undefinedError)
        @unknown default:
          self.canPlay = false
          self.state = .failed(error: Error.undefinedState)
        }
      }
    }
  }

  func setupPeriodicTimeObserver() {
    guard periodicTimeObserver == nil else { return }
    periodicTimeObserver = avPlayer.addPeriodicTimeObserver(
      forInterval: CMTimeMake(value: Int64(timeObservingMilliseconds), timescale: 1000),
      queue: .main
    ) { [weak self] time in
      // AVPlayer delivers the callback on the queue passed above (main).
      MainActor.assumeIsolated {
        guard let self, time.isValid else { return }

        if self.avPlayer.currentItem?.status == .failed,
           let error = self.avPlayer.currentItem?.error {
          self.state = .failed(error: error)
          self.removePeriodicTimeObserver()
          return
        }

        self.delegate?.mediaPlayer(self, didProgressToTime: time.seconds)
        let progress = self.duration > 0 ? Float(time.seconds / self.duration) : 0
        self.delegate?.mediaPlayer(self, onProgressUpdate: progress)
        self.handleLoopAtIntervalEnd(time: time)

        guard let currentItem = self.avPlayer.currentItem, currentItem.status == .readyToPlay else { return }
        currentItem.isPlaybackLikelyToKeepUp
        ? self.delegate?.mediaPlayer(didEndBuffering: self)
        : self.delegate?.mediaPlayer(didBeginBuffering: self)
      }
    }
  }

  func handleLoopAtIntervalEnd(time: CMTime) {
    guard (time.seconds + Double(timeObservingMilliseconds) / 1_000) >= playbackInterval.endAt else { return }

    if allowsLooping {
      setPlaybackPosition(to: playbackInterval.startAt)
      play()
      delegate?.mediaPlayer(didBeginReplay: self)
    }
  }

  func removePlayerItemObserver() {
    if let endOfPlaybackObserver {
      NotificationCenter.default.removeObserver(endOfPlaybackObserver)
      self.endOfPlaybackObserver = nil
    }
    playerItemObserver?.invalidate()
    playerItemObserver = nil
    observedPlayerItem = nil
  }

  func removePeriodicTimeObserver() {
    if let periodicTimeObserver {
      avPlayer.removeTimeObserver(periodicTimeObserver)
    }
    periodicTimeObserver = nil
  }

  func setPlaybackPosition(to value: Double) {
    avPlayer.seek(to: CMTimeMakeWithSeconds(value, preferredTimescale: 6_000))
  }

  func onStateUpdate() {
    delegate?.mediaPlayer(self, didUpdatePlaybackState: state)
    Logger.info("Player status: \(state.value)")

    switch state {
    case .playing:
      delegate?.mediaPlayer(didBeginPlayback: self)
    case .paused:
      delegate?.mediaPlayer(didPausePlayback: self)
    case .ended:
      delegate?.mediaPlayer(didEndPlayback: self)
    case .failed(error: let error):
      delegate?.mediaPlayer(self, didFailWithError: error)
    case .preparing, .readyToPlay, .stopped:
      break
    }
  }

}
