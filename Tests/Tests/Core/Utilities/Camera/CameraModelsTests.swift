//
//  CameraModelsTests.swift
//  PovioKit_Tests
//

import XCTest
import AVFoundation
@testable import PovioKitUtilities

final class CameraModelsTests: XCTestCase {
  func testCameraPositionMapsToAVCapturePosition() {
    XCTAssertEqual(Camera.CameraPosition.back.asAVCaptureDevicePosition, .back)
    XCTAssertEqual(Camera.CameraPosition.front.asAVCaptureDevicePosition, .front)
  }
  
  func testMediaTypeMapsToAVMediaType() {
    XCTAssertEqual(Camera.MediaType.video.asAVMediaType, .video)
    XCTAssertEqual(Camera.MediaType.audio.asAVMediaType, .audio)
  }
  
  func testCameraEnumsAreInstantiable() {
    let authStatuses: [Camera.CameraAuthorizationStatus] = [.authorized, .denied, .notDetermined]
    let errors: [Camera.Error] = [.unavailable, .missingSession, .missingInput, .missingOutput, .missingMetadata, .invalidImage]
    
    XCTAssertEqual(authStatuses.count, 3)
    XCTAssertEqual(errors.count, 6)
  }
}
