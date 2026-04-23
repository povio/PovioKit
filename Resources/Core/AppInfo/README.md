# AppInfo

A cross-platform namespace of small helpers for reading common
`Info.plist` metadata (app name, version, build, bundle id) and for
forwarding well-known deep-link URLs to the system opener.

All methods are static; there is nothing to instantiate.

## Bundle metadata

```swift
AppInfo.bundleId       // "com.example.app"
AppInfo.name           // "My App"
AppInfo.version        // "1.9.3"
AppInfo.build          // "84"
```

Each getter returns `nil` if the corresponding `Info.plist` key is
missing.

## Deep links

All helpers return `true` when the URL passed `canOpenURL` and was
forwarded for opening. When called off the main thread on iOS, a
`MainActor.assumeIsolated` precondition will trap — which is the
correct behavior because `UIApplication.open(_:options:)` is
main-thread only.

### Open an arbitrary URL

```swift
AppInfo.openUrl(URL(string: "https://example.com")!)
AppInfo.openUrl(url, inSafari: true)   // forces Safari on iOS 17.5+ / macOS
```

### Open the App Store listing for your app

```swift
AppInfo.openAppStore(appId: "123456789")
```

### Open the system Phone app

```swift
AppInfo.call("+1 (415) 555-1234")   // sanitised before passing to tel://
```

### Open the Settings app (iOS only)

```swift
AppInfo.openSettings()
AppInfo.openNotificationSettings()
```

## Testing

For deterministic tests, `AppInfoURLHandlerStore` exposes internal
`canOpenUrlHandlerForTesting` / `openUrlHandlerForTesting` seams that
replace the underlying `UIApplication` / `NSWorkspace` calls — see the
source for details.

## Source code

You can find source code [here](/Sources/Core/AppInfo.swift).
