//
//  MediaStreamTests.swift
//  PovioKit_Tests
//

import XCTest
import PovioKitUtilities

final class MediaStreamTests: XCTestCase {
  func testGenericAudioStreamStoresAllProperties() {
    let url = URL(string: "https://povio.com/audio.mp3")!
    let stream = GenericAudioStream(id: "track-1", title: "Track One", url: url)
    
    XCTAssertEqual(stream.id, "track-1")
    XCTAssertEqual(stream.title, "Track One")
    XCTAssertEqual(stream.url, url)
  }
  
  func testGenericAudioStreamConformsToMediaStreamProtocol() {
    let url = URL(string: "https://povio.com/audio.mp3")!
    let stream: MediaStream = GenericAudioStream(id: "track-2", title: "Track Two", url: url)
    
    XCTAssertEqual(stream.id, "track-2")
    XCTAssertEqual(stream.title, "Track Two")
    XCTAssertEqual(stream.url.absoluteString, "https://povio.com/audio.mp3")
  }
}
