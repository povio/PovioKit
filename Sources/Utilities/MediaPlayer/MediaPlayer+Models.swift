//
//  File.swift
//
//
//  Created by Borut Tomazin on 06/10/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension MediaPlayer {
  enum Error: Swift.Error {
    case undefinedState
    case undefinedError
  }
  
  /// Enum representing the different states of media playback.
  enum PlaybackState {
    /// State when the media player is preparing to play media.
    case preparing
    /// State when the media player is ready to start playing.
    case readyToPlay
    /// State when the media player is actively playing media.
    case playing
    /// State when the media player has paused media playback.
    case paused
    /// State when the media player has stopped media playback.
    case stopped
    /// State when the media player has ended media playback.
    case ended
    /// State when the media player failed to start or continue playback.
    case failed(error: Swift.Error)
  }
}

extension MediaPlayer.PlaybackState {
  var value: String {
    switch self {
    case .preparing:
      return "Preparing"
    case .readyToPlay:
      return "ReadyToPlay"
    case .playing:
      return "Playing"
    case .paused:
      return "Paused"
    case .stopped:
      return "Stopped"
    case .ended:
      return "Ended"
    case .failed(let error):
      return "Failed with \(error.localizedDescription)"
    }
  }
}

extension MediaPlayer.PlaybackState: Equatable {
  public static func == (lhs: MediaPlayer.PlaybackState, rhs: MediaPlayer.PlaybackState) -> Bool {
    switch (lhs, rhs) {
    case (.preparing, .preparing),
      (.readyToPlay, .readyToPlay),
      (.playing, .playing),
      (.paused, .paused),
      (.stopped, .stopped),
      (.ended, .ended):
      return true
    case (.failed(let lError), .failed(let rError)):
      return lError.localizedDescription == rError.localizedDescription
    default:
      return false
    }
  }
}

extension MediaPlayer.Error: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .undefinedState:
      return "MediaPlayer state is undefined!"
    case .undefinedError:
      return "MediaPlayer returned undefined error!"
    }
  }
}
