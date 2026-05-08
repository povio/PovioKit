<p align="center">
    <img src="Resources/PovioKit.png" width="400" max-width="90%" alt="PovioKit" />
</p>

<p align="center">
    <a href="https://swiftpackageindex.com/povio/PovioKit" alt="Swift Package Index">
        <img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" />
    </a>
    <a href="https://www.swift.org" alt="Swift">
        <img src="https://img.shields.io/badge/Swift-6-orange.svg" />
    </a>
    <a href="https://povio.github.io/PovioKit/" alt="Documentation">
        <img src="https://img.shields.io/badge/docs-DocC-blue.svg" />
    </a>
    <a href="./LICENSE" alt="License">
        <img src="https://img.shields.io/badge/Licence-MIT-red.svg" />
    </a>
    <a href="https://github.com/povio/PovioKit/actions/workflows/Tests.yml" alt="Tests Status">
        <img src="https://github.com/povio/PovioKit/actions/workflows/Tests.yml/badge.svg" />
    </a>
</p>

<p align="center">
    A modular Swift 6 toolkit of concurrency helpers, Foundation
    extensions, SwiftUI / UIKit / AppKit components, and focused
    utilities (Money, MediaPlayer, IAP, Camera, Exif, property
    wrappers, …) — all compiled under strict concurrency.
</p>

## At a glance

```swift
import PovioKitAsync
import PovioKitUtilities

// Retry a flaky network call with exponential backoff + jitter.
let data = try await retry(
  policy: .init(
    maxAttempts: 3,
    initialDelay: .milliseconds(250),
    backoffFactor: 2,
    jitter: .milliseconds(100)
  )
) {
  try await api.fetchProfile()
}

// Bound an operation with a timeout.
let result = try await withTimeout(.seconds(2)) {
  try await heavyWork()
}

// Typed money, no silent currency mixing.
let usd = Money(amount: 1_299, currency: .usd)
let eur = Money(amount:   999, currency: .eur)

try usd + usd    // OK
try usd + eur    // throws Money.ArithmeticError.currencyMismatch
```

## Modules

Built with the Swift 6 toolchain and Swift 6 language mode.

| Product | iOS 17+ | macOS 14+ | Notes |
| :- | :-: | :-: | :- |
| [`PovioKitCore`](Resources/Core) | Yes | Yes | Foundation-first shared primitives and extensions. |
| [`PovioKitUtilities`](Resources/Utilities) | Yes | Yes | Money, MediaPlayer, IAP, Camera, Exif, property wrappers, and more. |
| [`PovioKitAsync`](Resources/Async) | Yes | Yes | `async`/`await` sequences, retry, timeout, race, semaphore, coalescer. |
| [`PovioKitSwiftUI`](Resources/UI/SwiftUI) | Yes | Yes | SwiftUI views and view modifiers. |
| [`PovioKitUIKit`](Resources/UI/UIKit) | Yes | No | UIKit-only APIs. |
| [`PovioKitAppKit`](Resources/UI/AppKit) | No | Yes | AppKit-only APIs. |

## Requirements

- Xcode 16 or newer
- Swift 6 (language mode enabled)
- iOS 17 / macOS 14 or newer

## Installation

### Swift Package Manager
- In Xcode, click `File` -> `Add Package Dependencies...`  
- Insert `https://github.com/povio/PovioKit` in the Search field.
- Select a desired `Dependency Rule`. Usually "Up to Next Major Version" with "7.0.0".
- Select "Add Package" button and check one or all given products from the list:
  - *PovioKitCore* (core library)
  - *PovioKitUtilities* (utility components)
  - *PovioKitAsync* (async/await components)
  - *PovioKitUIKit* (UIKit components)
  - *PovioKitSwiftUI* (SwiftUI components)
  - *PovioKitAppKit* (AppKit components)
- Select "Add Package" again and you are done.

### Package Collection

Discover PovioKit alongside our other open-source Swift libraries
(authentication, networking, …) via our Swift Package Collection.

**Add via Xcode:**
1. Open Xcode → Settings → Swift Packages
2. Click the **+** button
3. Enter: `https://raw.githubusercontent.com/povio/PovioKit/main/Collections/poviokit.json`
4. Click **Add**

**Add via Command Line:**
```bash
swift package-collection add https://raw.githubusercontent.com/povio/PovioKit/main/Collections/poviokit.json
```

The collection includes:
- **PovioKit** — this repository (Core, Utilities, UIKit, SwiftUI, AppKit, Async).
- **[PovioKitNetworking](https://github.com/povio/PovioKitNetworking)** — networking helpers and PromiseKit bindings.
- **[PovioKitAuth](https://github.com/povio/PovioKitAuth)** — authentication core with Apple and LinkedIn providers.
- **[PovioKitAuthGoogle](https://github.com/povio/PovioKitAuthGoogle)** — Google Sign-In provider.
- **[PovioKitAuthFacebook](https://github.com/povio/PovioKitAuthFacebook)** — Facebook Login provider.

## Migration

Please read the [Migration](MIGRATING.md) document.

## Documentation

API documentation is generated with DocC and published through GitHub
Pages at **[povio.github.io/PovioKit](https://povio.github.io/PovioKit/)**.
Per-module entry points:

- [`PovioKitCore`](https://povio.github.io/PovioKit/PovioKitCore/documentation/poviokitcore/)
- [`PovioKitUtilities`](https://povio.github.io/PovioKit/PovioKitUtilities/documentation/poviokitutilities/)
- [`PovioKitAsync`](https://povio.github.io/PovioKit/PovioKitAsync/documentation/poviokitasync/)
- [`PovioKitUIKit`](https://povio.github.io/PovioKit/PovioKitUIKit/documentation/poviokituikit/)
- [`PovioKitSwiftUI`](https://povio.github.io/PovioKit/PovioKitSwiftUI/documentation/poviokitswiftui/)
- [`PovioKitAppKit`](https://povio.github.io/PovioKit/PovioKitAppKit/documentation/poviokitappkit/)

## Contributing

Contributions are very welcome.

- Run the full test suite locally with `swift test`, or open
  `Package.swift` in Xcode and use the `PovioKit-Package` scheme.
- CI builds the package against the declared minimum deployment
  targets (iOS 17 / macOS 14) on every pull request, in addition to
  the current Xcode default simulator.
- For substantial API changes, please open an issue first so we can
  discuss the shape before you invest time.

## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
