//
//  UIImageTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 26/09/2024.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import UIKit
import PovioKitCore

class UIImageTests: XCTestCase {
  private let image: UIImage? = UIImage(named: "PovioKit", in: .module, with: nil)
  
  func testDownsizeToTargetSize() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Downsizing...")
    
    Task {
      do {
        let downsizedImage = try await image.downsize(toTargetSize: .init(size: 200))
        XCTAssertLessThanOrEqual(downsizedImage.size.width, 200, "The width of the downsized image should be 200")
        XCTAssertLessThanOrEqual(downsizedImage.size.height, 200, "The height of the downsized image should be 200")
      } catch {
        XCTFail("The image failed to downsize.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testDownsizeByPercentage() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Downsizing...")
    let originalSize = image.size
    
    Task {
      do {
        let downsizedImage = try await image.downsize(byPercentage: 50)
        XCTAssertEqual(downsizedImage.size.width, originalSize.width / 2, "The width of the downsized image should be 200")
        XCTAssertEqual(downsizedImage.size.height, originalSize.height / 2, "The height of the downsized image should be 200")
      } catch {
        XCTFail("The image failed to downsize.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressWithPngFormat() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    Task {
      do {
        let downsizedImage = try await image.compress(toFormat: .png)
        // verify the image format by checking the PNG signature
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let downsizedImageSignature = [UInt8](downsizedImage.prefix(pngSignature.count))
        
        XCTAssertEqual(downsizedImageSignature, pngSignature, "The image was not compressed as PNG.")
      } catch {
        XCTFail("The image failed to compress.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressWithJpgFormat() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    Task {
      do {
        let downsizedImage = try await image.compress(toFormat: .jpeg(compressionRatio: 0.5))
        // verify the image format by checking the JPEG signature
        let jpegSignature: [UInt8] = [0xFF, 0xD8]
        let downsizedImageSignature = [UInt8](downsizedImage.prefix(jpegSignature.count))
        
        XCTAssertEqual(downsizedImageSignature, jpegSignature, "The image was not compressed as JPEG.")
      } catch {
        XCTFail("The image failed to compress.")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
  
  func testCompressToMaxSize() {
    guard let image else { XCTFail("Failed to load image"); return }
    let promise = expectation(description: "Compressing...")
    
    let targetKB = 10.0
    
    Task {
      do {
        let downsizedImage = try await image.compress(toMaxKbSize: targetKB)
        // Check if the size is 1KB or less
        let imageSizeInKB = Double(downsizedImage.count) / 1024.0
        XCTAssertLessThanOrEqual(imageSizeInKB, targetKB, "The compressed image size is greater than 1KB.")
      } catch {
        XCTFail("The image failed to compress. \(error)")
      }
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 1)
  }
}
#endif
