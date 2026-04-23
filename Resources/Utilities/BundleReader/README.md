# BundleReader

A tiny abstraction over `Bundle.object(forInfoDictionaryKey:)` that
keeps reads from the app bundle injectable and test-friendly.

It is primarily used internally by the
[`@XCConfigValue`](../PropertyWrapper/XCConfigValue) property wrapper,
but it is fully `public` and can be used anywhere you want to read
`Info.plist`-style values without reaching for `Bundle.main` directly.

## Protocol

```swift
public protocol BundleReadable: Sendable {
  func object(forInfoDictionaryKey key: String) -> Any?
}
```

## Default implementation

```swift
public final class BundleReader: BundleReadable {
  public init(bundle: Bundle = .main)
  public func object(forInfoDictionaryKey key: String) -> Any?
}
```

## Usage

### Production

```swift
let reader = BundleReader()
let endpoint = reader.object(forInfoDictionaryKey: "API_BASE_URL") as? String
```

### Tests

Inject a mock:

```swift
final class MockBundleReader: BundleReadable {
  var values: [String: Any]
  init(values: [String: Any]) { self.values = values }
  func object(forInfoDictionaryKey key: String) -> Any? { values[key] }
}

@XCConfigValue(
  key: "API_BASE_URL",
  bundleReader: MockBundleReader(values: ["API_BASE_URL": "https://staging.example.com"])
)
static var apiBaseURL: String = "https://example.com"
```

## Source code

You can find source code [here](/Sources/Utilities/BundleReader/BundleReader.swift).
