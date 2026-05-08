# XCConfigValue

A property wrapper that reads values from the app bundle's `Info.plist`
— typically values piped in from build-configuration files.

## Usage

Configure `.xcconfig` files such as `Production.xcconfig` and
`Development.xcconfig`:

```xcconfig
API_BASE_URL = api.example.com
SUBSCRIBE_LIMIT = 10
```

Reference them from `Info.plist` using the `$(BUILD_SETTING_NAME)`
substitution syntax. Then declare the values in Swift with a **required
default** — the default is returned whenever the key is missing or the
value can't be converted to the declared type:

```swift
enum Environment {
  @XCConfigValue(key: "API_BASE_URL")
  static var baseUrl: String = "https://example.com"

  @XCConfigValue(key: "SUBSCRIBE_LIMIT")
  static var subscribeLimit: Int = 10
}
```

## Missing or unconvertible values

Starting with PovioKit 7, the wrapper no longer terminates the process
on missing keys or unconvertible values. It logs a descriptive error via
`Logger.error` and returns the `defaultValue` instead. This makes the
wrapper safer to use from early app-launch code paths and from previews
where the `Info.plist` may not contain the key.

## Testing

`XCConfigValue` reads through a `BundleReadable` protocol. In tests,
inject a mock reader to drive custom values:

```swift
@XCConfigValue(key: "API_BASE_URL", bundleReader: MockBundleReader())
static var baseUrl: String = "https://example.com"
```

See [`BundleReader`](../../BundleReader) for details.

## Source code

You can find source code [here](/Sources/Utilities/PropertyWrapper/XCConfigValue.swift).
