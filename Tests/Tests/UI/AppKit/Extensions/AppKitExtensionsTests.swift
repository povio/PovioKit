#if os(macOS)
import XCTest
import AppKit
@testable import PovioKitAppKit

// `NSWindow` / `NSView` initializers and properties are
// `@MainActor`-isolated on recent SDKs, so the suite runs on the
// main actor — matching how XCTest drives `XCTestCase` methods.
@MainActor
final class AppKitExtensionsTests: XCTestCase {
  func testWindowBoundsUsesFrameSizeWithZeroOrigin() {
    let contentRect = NSRect(x: 24, y: 32, width: 320, height: 180)
    let window = NSWindow(
      contentRect: contentRect,
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )

    XCTAssertEqual(window.bounds.origin.x, 0)
    XCTAssertEqual(window.bounds.origin.y, 0)
    XCTAssertEqual(window.bounds.size.width, window.frame.width)
    XCTAssertEqual(window.bounds.size.height, window.frame.height)
  }

  func testRenderAsImageReturnsImageMatchingViewSize() {
    let view = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 80))

    let image = view.renderAsImage()

    XCTAssertNotNil(image)
    XCTAssertEqual(image?.size.width, 120)
    XCTAssertEqual(image?.size.height, 80)
  }
}
#endif
