//
//  MediaPlayerModelsTests.swift
//  PovioKit_Tests
//

import XCTest
@testable import PovioKitUtilities

final class MediaPlayerModelsTests: XCTestCase {
  private enum MockError: Error, LocalizedError {
    case sample
    var errorDescription: String? { "Sample error" }
  }
  
  func testPlaybackStateValueMapping() {
    XCTAssertEqual(MediaPlayer.PlaybackState.preparing.value, "Preparing")
    XCTAssertEqual(MediaPlayer.PlaybackState.readyToPlay.value, "ReadyToPlay")
    XCTAssertEqual(MediaPlayer.PlaybackState.playing.value, "Playing")
    XCTAssertEqual(MediaPlayer.PlaybackState.paused.value, "Paused")
    XCTAssertEqual(MediaPlayer.PlaybackState.stopped.value, "Stopped")
    XCTAssertEqual(MediaPlayer.PlaybackState.ended.value, "Ended")
    XCTAssertEqual(MediaPlayer.PlaybackState.failed(error: MockError.sample).value, "Failed with Sample error")
  }
  
  func testPlaybackStateEquatable() {
    XCTAssertEqual(MediaPlayer.PlaybackState.preparing, .preparing)
    XCTAssertEqual(MediaPlayer.PlaybackState.readyToPlay, .readyToPlay)
    XCTAssertEqual(MediaPlayer.PlaybackState.playing, .playing)
    XCTAssertEqual(MediaPlayer.PlaybackState.paused, .paused)
    XCTAssertEqual(MediaPlayer.PlaybackState.stopped, .stopped)
    XCTAssertEqual(MediaPlayer.PlaybackState.ended, .ended)
    XCTAssertEqual(MediaPlayer.PlaybackState.failed(error: MockError.sample), .failed(error: MockError.sample))
    XCTAssertNotEqual(MediaPlayer.PlaybackState.playing, .paused)
  }
  
  func testMediaPlayerErrorDescriptions() {
    XCTAssertEqual(MediaPlayer.Error.undefinedState.localizedDescription, "MediaPlayer state is undefined!")
    XCTAssertEqual(MediaPlayer.Error.undefinedError.localizedDescription, "MediaPlayer returned undefined error!")
  }
}
