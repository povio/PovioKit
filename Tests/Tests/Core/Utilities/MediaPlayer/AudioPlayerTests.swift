//
//  AudioPlayerTests.swift
//  PovioKit_Tests
//

import XCTest
import PovioKitUtilities

final class AudioPlayerTests: XCTestCase {
  private func stream(id: String) -> GenericAudioStream {
    GenericAudioStream(id: id, title: "Stream \(id)", url: URL(string: "https://povio.com/\(id).mp3")!)
  }
  
  func testInitWithStreamsSelectsFirstStream() {
    let first = stream(id: "1")
    let second = stream(id: "2")
    
    let player = AudioPlayer(streams: [first, second])
    
    XCTAssertEqual(player.streams.count, 2)
    XCTAssertEqual(player.currentStream?.id, "1")
    XCTAssertNotNil(player.currentItem)
  }
  
  func testSelectAudioUpdatesCurrentStream() {
    let player = AudioPlayer(streams: [stream(id: "1")])
    let target = stream(id: "2")
    
    player.selectAudio(stream: target)
    
    XCTAssertEqual(player.currentStream?.id, "2")
    XCTAssertNotNil(player.currentItem)
  }
  
  func testPlayNextMovesToNextStreamWhenAvailable() {
    let first = stream(id: "1")
    let second = stream(id: "2")
    let player = AudioPlayer(streams: [first, second])
    
    player.playNext()
    
    XCTAssertEqual(player.currentStream?.id, "2")
  }
  
  func testPlayPreviousMovesToPreviousStreamWhenAvailable() {
    let first = stream(id: "1")
    let second = stream(id: "2")
    let player = AudioPlayer(streams: [first, second])
    player.selectAudio(stream: second)
    
    player.playPrevious()
    
    XCTAssertEqual(player.currentStream?.id, "1")
  }
  
  func testPlayNextAtEndStopsWithoutChangingCurrentStream() {
    let first = stream(id: "1")
    let second = stream(id: "2")
    let player = AudioPlayer(streams: [first, second])
    player.selectAudio(stream: second)
    
    player.playNext()
    
    XCTAssertEqual(player.currentStream?.id, "2")
    XCTAssertEqual(player.state, .stopped)
  }
  
  func testPlayPreviousAtBeginningStopsWithoutChangingCurrentStream() {
    let first = stream(id: "1")
    let second = stream(id: "2")
    let player = AudioPlayer(streams: [first, second])
    player.selectAudio(stream: first)
    
    player.playPrevious()
    
    XCTAssertEqual(player.currentStream?.id, "1")
    XCTAssertEqual(player.state, .stopped)
  }
}
