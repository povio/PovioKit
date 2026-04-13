//
//  MediaPlayerBehaviorTests.swift
//  PovioKit_Tests
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitUtilities

final class MediaPlayerBehaviorTests: XCTestCase {
  private final class DelegateSpy: MediaPlayerDelegate {
    var beginPlaybackCount = 0
    var endPlaybackCount = 0
    var pausePlaybackCount = 0
    var replayCount = 0
    var beginBufferingCount = 0
    var endBufferingCount = 0
    var progressedTimes: [Double] = []
    var progressUpdates: [Float] = []
    var failedErrors: [Swift.Error] = []
    var updatedStates: [MediaPlayer.PlaybackState] = []
    
    func mediaPlayer(didBeginPlayback player: MediaPlayer) { beginPlaybackCount += 1 }
    func mediaPlayer(didEndPlayback player: MediaPlayer) { endPlaybackCount += 1 }
    func mediaPlayer(didPausePlayback player: MediaPlayer) { pausePlaybackCount += 1 }
    func mediaPlayer(didBeginReplay player: MediaPlayer) { replayCount += 1 }
    func mediaPlayer(didBeginBuffering player: MediaPlayer) { beginBufferingCount += 1 }
    func mediaPlayer(didEndBuffering player: MediaPlayer) { endBufferingCount += 1 }
    func mediaPlayer(_ player: MediaPlayer, didProgressToTime seconds: Double) { progressedTimes.append(seconds) }
    func mediaPlayer(_ player: MediaPlayer, onProgressUpdate progress: Float) { progressUpdates.append(progress) }
    func mediaPlayer(_ player: MediaPlayer, didFailWithError error: Swift.Error) { failedErrors.append(error) }
    func mediaPlayer(_ player: MediaPlayer, didUpdatePlaybackState playbackState: MediaPlayer.PlaybackState) { updatedStates.append(playbackState) }
  }
  
  private enum MockError: Swift.Error, LocalizedError {
    case sample
    var errorDescription: String? { "Sample media error" }
  }
  
  func testStateChangesNotifyDelegate() {
    let player = MediaPlayer()
    let spy = DelegateSpy()
    player.delegate = spy
    
    player.state = .playing
    player.state = .paused
    player.state = .ended
    player.state = .failed(error: MockError.sample)
    
    XCTAssertEqual(spy.beginPlaybackCount, 1)
    XCTAssertEqual(spy.pausePlaybackCount, 1)
    XCTAssertEqual(spy.endPlaybackCount, 1)
    XCTAssertEqual(spy.failedErrors.count, 1)
    XCTAssertEqual(spy.updatedStates.count, 4)
  }
  
  func testUpdatePlaybackIntervalUpdatesRangeWhenValid() {
    let player = MediaPlayer()
    
    player.updatePlaybackInterval(startAt: 1, endAt: 3)
    
    XCTAssertEqual(player.playbackInterval.startAt, 1, accuracy: 0.001)
    XCTAssertEqual(player.playbackInterval.endAt, 3, accuracy: 0.001)
  }
  
  func testUpdatePlaybackIntervalKeepsRangeWhenInvalid() {
    let player = MediaPlayer()
    player.updatePlaybackInterval(startAt: 1, endAt: 3)
    
    player.updatePlaybackInterval(startAt: 3, endAt: 1)
    
    XCTAssertEqual(player.playbackInterval.startAt, 1, accuracy: 0.001)
    XCTAssertEqual(player.playbackInterval.endAt, 3, accuracy: 0.001)
  }
  
  func testReplaceCurrentItemResetsPlaybackInterval() {
    let player = MediaPlayer()
    player.updatePlaybackInterval(startAt: 2, endAt: 4)
    
    player.replaceCurrentItem(with: nil)
    
    XCTAssertEqual(player.playbackInterval.startAt, 0, accuracy: 0.001)
  }
  
  func testPlayFromAndPlayRangeInvalidInputDoesNotCrash() {
    let player = MediaPlayer()
    
    XCTAssertNoThrow(player.play(from: 10))
    XCTAssertNoThrow(player.play(from: 5, to: 1))
  }
  
  func testPauseAndStopUpdateState() {
    let player = MediaPlayer()
    
    player.pause()
    XCTAssertEqual(player.state, .paused)
    
    player.stop()
    XCTAssertEqual(player.state, .stopped)
  }
}
