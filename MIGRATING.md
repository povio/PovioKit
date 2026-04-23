## Migration Guides

### Migration from versions < 7.0.0

This release contains several source-breaking changes. The changes fall into
five themes: a tooling/platform bump to Swift 6 + iOS 17 / macOS 14,
correctness fixes in concurrency-sensitive types, the removal of unsound
`Money` semantics, a rename of the async sequence family so names match
behavior, and the removal of the retroactive `URL` string-literal
conformance.

**Package – tooling and platforms**
* The package now requires the Swift 6.0 toolchain (Xcode 16+). The
  `swift-tools-version` was bumped from `5.9` to `6.0`.
* Minimum deployment targets are now iOS 17 and macOS 14 (previously
  iOS 16 and macOS 13). Consumers still on iOS 16 / macOS 13 should pin
  to the `6.x` line.
* Every target — including the test target — now compiles under the
  Swift 6 language mode. The previous
  `.enableExperimentalFeature("StrictConcurrency")` setting and the
  `swiftLanguageVersions: [.v5]` list have both been removed; neither
  is needed once `swift-tools-version:6.0` is in effect.

**Utilities – property wrappers under Swift 6**
* `UserDefault<Value>` now conforms to `@unchecked Sendable`, and its
  `wrappedValue` setter is `nonmutating`. The wrapper can therefore
  be used on `let` instance properties (previously the mutating setter
  forced callers to use `var`). All stored state in the wrapper is
  immutable or thread-safe at runtime; the `@unchecked` is a
  type-system concession for `UserDefaults` / `JSONEncoder` /
  `JSONDecoder`, which are documented-thread-safe but not
  `Sendable`-annotated by Foundation.
* `UserDefaultKey<Value>` is now a `final` class and conforms to
  `@unchecked Sendable` for the same reasons.
* `XCConfigValue<Value>` now requires `Value: Sendable` (in addition
  to the existing `LosslessStringConvertible`) and conforms to
  `Sendable`. `BundleReadable` inherits from `Sendable`, and the
  built-in `BundleReader` conforms via `@unchecked Sendable`.
  Consumer types implementing `BundleReadable` must also be
  `Sendable` or `@unchecked Sendable`.
* **`@UserDefault` / `@XCConfigValue` on `static var`**: the
  wrappers themselves are now `Sendable`, but Swift 6 treats any
  writable `static var` — including those synthesized by a property
  wrapper — as non-concurrency-safe global mutable state unless the
  declaration is isolated to a global actor. The recommended pattern
  is to put such declarations in a `@MainActor`-annotated enum or
  struct, e.g.:
  ```swift
  @MainActor
  enum AppDefaults {
    @UserDefault(defaultValue: false, key: "is_authenticated")
    static var isAuthenticated: Bool
  }
  ```
  Access from background contexts must then `await MainActor.run { … }`
  (or be `@MainActor` itself). As an escape hatch for call sites that
  are already protected by external synchronisation, the declaration
  can be marked `nonisolated(unsafe)`.

**Async**
* Renamed `AsyncThrottleSequence` → `AsyncDebounceSequence`. The
  `.throttle(clock:delayBetweenTasks:)` extension is now
  `.debounce(clock:delayBetweenTasks:)`. The behavior is unchanged (it was
  already a caller-driven debounce).
* The previous `AsyncDebounceSequence` (source-driven "emit the latest value
  per window") has been renamed to `AsyncSampleSequence`. The extension is
  now `.sample(clock:delayBetweenElements:)`.
* `AsyncSemaphore.acquire()` no longer contains a race between the
  permit-check and the continuation registration. No API change, but any
  custom tests that depended on the old ordering may need review.
* `TaskCoalescer.value(for:)` now tracks a generation ID per task. If a
  caller cancels an in-flight task and immediately submits a new one for
  the same key, the new task is no longer wiped out by the cleanup of the
  previous one. No API change.

**Utilities – Money**
* `Money` no longer conforms to `Comparable` and no longer defines `<`,
  `>`, `<=`, `>=` operators. Mixed-currency ordering was unsound. Use the
  explicit throwing APIs:
  ```swift
  let isGreater = try a.isGreaterThan(b)
  let isLessOrEqual = try a.isLessThanOrEqual(to: b)
  ```
  These throw `Money.OrderingError.currencyMismatch` when operands use
  different currencies. `XCTAssertGreaterThan(a, b)` and similar helpers
  will no longer compile for `Money` values.
* `+` and `-` between two `Money` values now `throw`
  `Money.ArithmeticError.currencyMismatch` instead of calling
  `fatalError` when currencies differ. Call sites must use `try`.
* The `Money * Money` operator has been removed. It produced values
  with units of `cents²`, which is mathematically meaningless for money.
  Use `Money * Int` / `Int * Money` for scalar multiplication.
* `Money.isPositive` now returns `true` only when `amount > 0`
  (previously it also returned `true` for zero).
* `Money` no longer conforms to `ExpressibleByFloatLiteral`. The old
  conformance silently truncated the decimal portion of literals such as
  `1.99`. Construct `Money` explicitly with `Money(amount:currency:…)`.
* The `Comparable.clamped(to:)` extension has been moved out of
  `PovioKitUtilities/Money/Money+Extensions.swift` and into
  `PovioKitCore/Extensions/Foundation/Comparable+PovioKit.swift`. Consumers
  that used `clamped(to:)` only via `import PovioKitUtilities` now also
  need `import PovioKitCore`.

**Utilities – InAppPurchaseService**
* `InAppPurchaseService` is now an `actor`. All mutable state is now
  properly isolated. The initializer no longer blocks, so if you need to
  observe the initial product list before using the service, `await` the
  new `bootstrap()` method:
  ```swift
  let service = InAppPurchaseService(identifiers: ids)
  await service.bootstrap()
  ```
* `validateReceipt()` is `nonisolated`: it performs only a local file
  read, so it can still be called from synchronous contexts without
  `await`.

**Core – URL**
* The retroactive `URL: ExpressibleByStringLiteral` conformance (and the
  accompanying `ExpressibleByExtendedGraphemeClusterLiteral` /
  `ExpressibleByUnicodeScalarLiteral` shims) have been removed. Retroactive
  conformances on types you do not own are a hazard in Swift 6 and break
  when two libraries both implement them. Replace:
  ```swift
  let url: URL = "https://povio.com"
  ```
  with either:
  ```swift
  let url = URL.require("https://povio.com")
  ```
  when the input is a static literal you know to be valid, or with the
  failable `URL(string:)` initializer when the input may be invalid.
* `URL.queryParameters` is now typed `[String: String]?` instead of
  `[AnyHashable: Any]?`. Callers that relied on `as? String` casts can
  remove those casts.

**Utilities – MediaPlayer / AudioPlayer**
* `MediaPlayer` no longer inherits from `AVPlayer`, and `AudioPlayer` no
  longer inherits from `MediaPlayer`. Both types now use composition:
  - `MediaPlayer` exposes the wrapped player as `mediaPlayer.avPlayer`.
  - `AudioPlayer` exposes the wrapped media player as
    `audioPlayer.mediaPlayer`.
  Call sites that previously relied on the inherited `AVPlayer` surface
  (e.g. `audioPlayer.rate`, `audioPlayer.volume`, `audioPlayer.replaceCurrentItem(with:)`,
  hand-off to an `AVPlayerLayer`) must drill into the exposed
  `avPlayer` instead. The domain-level API (`play`, `pause`, `stop`,
  `play(from:)`, `play(from:to:)`, `jump(to:)`, `seekForward`,
  `seekBackward`, `updatePlaybackInterval`) is preserved.
* `MediaPlayer.replaceCurrentItem(with:)` has been renamed to
  `MediaPlayer.replace(with:)` — it no longer overrides an `AVPlayer`
  method, so the `Current…` suffix added noise.
* Both classes are now `@MainActor`-isolated, matching the thread
  affinity of AVPlayer's playback and observer callbacks. Delegate
  methods on `MediaPlayerDelegate` are likewise `@MainActor`. Call
  sites that invoked these types from background contexts must `await`
  the hop to the main actor.
* `MediaPlayer.state` is now `public internal(set)`. Tests that poked
  the state directly must switch to `@testable import PovioKitUtilities`;
  production callers cannot set state at all (drive it through
  `play`/`pause`/`stop` instead).
* `MediaPlayer.timeObservingMiliseconds` has been renamed to
  `timeObservingMilliseconds` (spelling fix).
* `MediaStream` now conforms to `Sendable`. Concrete types must be
  value types or `Sendable`-safe reference types.

**Utilities – Debouncer / Throttler**
* `Throttler` has been removed. It was a trailing-edge debouncer under a
  misleading name — its behavior was identical to `Debouncer(behavior: .trailing)`.
  Replace:
  ```swift
  let throttler = Throttler(queue: .main, delay: .milliseconds(500))
  throttler.execute { ... }
  throttler.cancelPendingJob()
  ```
  with:
  ```swift
  let debouncer = Debouncer(delay: .milliseconds(500))
  debouncer.execute { ... }
  debouncer.cancel()
  ```
* `Debouncer` has been re-implemented on top of Swift Concurrency
  (`Task.sleep(for:)`) and no longer takes a `queue:` parameter. Submitted
  closures are `@Sendable` and may run on any executor; wrap with
  `Task { @MainActor in ... }` if you need main-thread execution.
* `Debouncer.delay` is now typed `Duration` instead of
  `DispatchTimeInterval`. Literals of the form `.milliseconds(…)`,
  `.seconds(…)` etc. continue to work because `Duration` provides matching
  factory methods. Call sites that stored or passed the delay through as
  `DispatchTimeInterval` need to switch to `Duration`.
* `Debouncer.cancelPendingJob()` has been renamed to `Debouncer.cancel()`.
  A deprecated alias is kept for one release.

**Core – Logger**
* `Logger.shared.logLevel` is now guarded by an internal lock and is
  safe to read and write from multiple threads. `os.Logger` instances are
  cached per file category so the OSLog subsystem/category configuration
  applies consistently. The public API is unchanged.

**Core – AppInfo**
* `AppInfo.bundleId`, `AppInfo.name`, `AppInfo.build`, and
  `AppInfo.version` now return `String?`. Previously they returned the
  placeholder `"/"` when the corresponding `Info.plist` key was missing.
  Callers that relied on the fallback should use `??` or optional
  chaining:
  ```swift
  let version = AppInfo.version ?? "n/a"
  ```

**Core – Double.convert**
* `Double.convert(from:to:)` now returns `.nan` (instead of terminating
  the process via `Measurement.converted(to:)`) when `from` and `to`
  belong to different `Dimension` types, for example
  `Double.convert(from: UnitLength.meters, to: UnitMass.kilograms)`.
  Callers should inspect `result.isNaN` (or `result.isFinite`) when
  dimensions may be user-supplied.

**Utilities – Delegated**
* `Delegated<Input, Output>.callAsFunction(_:)` now returns `Output?`
  instead of `Output`. Previously it would `fatalError` when invoked
  before a delegate had been attached. Call sites that relied on the
  non-optional return must unwrap:
  ```swift
  let result = delegated(input) ?? defaultValue
  ```
  The `Output == Void` specializations are unchanged.

**Utilities – XCConfigValue**
* `@XCConfigValue` now requires a default value supplied via the
  `= …` initializer syntax, e.g.
  ```swift
  @XCConfigValue(key: "API_BASE_URL")
  static var apiBaseURL: String = "https://example.com"
  ```
  Missing keys and type-mismatches no longer terminate the process via
  `fatalError`; they now log via `PovioKitCore.Logger` and return the
  default value.

**Utilities – DispatchTimer**
* Mutations of `DispatchTimer`'s internal `DispatchSourceTimer` are now
  guarded by an internal `NSLock`, making `schedule`, `stop`, and
  `isActive` safe to call from multiple threads. The public API is
  unchanged. `DispatchTimer` now conforms to `Sendable` (via
  `@unchecked`), and the `completion` closures are `@Sendable`.

**Utilities – Broadcast**
* `Broadcast.observers` is no longer part of the public API, and the
  internal `Weak` helper type is now truly `private`. Production code
  almost never read `observers` directly, but tests or mirrors that
  did will need to use the new `observerCount` diagnostic property
  instead.
* `Broadcast`'s documentation now states the long-standing requirement
  that `T` be a class-bound type (a concrete class or a protocol
  declared with `: AnyObject`). Using value types silently produces
  stale observers because the underlying weak reference cannot retain
  them; this has always been the case but is now called out
  explicitly.

**Utilities – Camera / QRCodeScanner**
* `QRCodeScanner.prepare()` is now idempotent. Re-calling it no longer
  stacks duplicate `AVCaptureDeviceInput` / output registrations that
  could fail the second configuration. Behaviour matches
  `PhotoCamera.prepare()`.
* `QRCodeScanner` no longer calls `delegate?.scanFailure()` for
  ordinary metadata frames (empty batches, non-QR types). The delegate
  is now invoked only when a QR code is detected whose `stringValue`
  cannot be decoded.
* `PhotoCamera.takePhoto(...)` no longer takes a
  `videoOrientation: AVCaptureVideoOrientation?` parameter; that type
  and the corresponding `AVCaptureConnection.videoOrientation` property
  were deprecated in iOS 17. Both overloads now accept a
  `videoRotationAngle: CGFloat?` instead, measured in degrees. Call
  sites must migrate as follows:
  ```swift
  // before
  camera.takePhoto(videoOrientation: .portrait)
  camera.takePhoto(videoOrientation: .landscapeRight)

  // after
  camera.takePhoto(videoRotationAngle: 90)   // portrait
  camera.takePhoto(videoRotationAngle: 0)    // landscape right
  ```
  Passing `nil` preserves the pre-7.0 behaviour of falling back to the
  preview layer's current angle, and portrait (`90°`) is still used when
  neither the requested angle nor the preview angle is supported by the
  capture connection.
* Session topology mutation in `PhotoCamera` / `QRCodeScanner`
  (`configure()` paths reached from `prepare()`, `setCameraPosition(_:)`,
  and `setDeviceType(_:)`) is now serialised on `Camera.sessionQueue`.
  This matches the documented threading contract and prevents races
  with `startSession()` / `stopSession()`. Callers that were already
  invoking these methods from arbitrary threads don't need to change
  anything; behaviour is strictly safer.

**Async – AsyncDebounceSequence**
* `AsyncDebounceSequence.Iterator.next()` now rethrows
  `CancellationError` when the caller's enclosing `Task` is cancelled.
  Before 7.0 it would silently map any cancellation to `nil`, making
  the sequence indistinguishable from "no more elements". Internal
  debounce-replacement cancellation still produces `nil` as before.

**Swift 6 strict concurrency**
* The package is now built with `-strict-concurrency=complete`
  enabled at every target. Consumers that integrate PovioKit and enable
  strict concurrency in their own app no longer see warnings emanating
  from PovioKit source.
* `AsyncDebounceSequence` now requires `BaseSequence: Sendable`,
  `BaseSequence.Element: Sendable`, and `BaseSequence.AsyncIterator:
  Sendable`. The `.debounce(clock:delayBetweenTasks:)` extension on
  `AsyncSequence` has the same constraints. Call sites that passed
  non-`Sendable` custom sequences will no longer compile.
* `race`, `withTimeout`, and `retry` in `PovioKitAsync` now require the
  return type `R` to be `Sendable`. The underlying task-group APIs
  already demanded this; the constraint is now explicit.
* `NotificationCenter.observe(_:…, callback:)` and its array overload
  now require a `@Sendable` callback. `PovioNotificationRepresentable`
  and the default `AppNotification` enum gained `Sendable` conformance.
* `Broadcast<T>.invoke(on:invocation:)` now requires a `@Sendable`
  closure so it can be dispatched across queues safely.
* `Money.Defaults` now conforms to `Sendable`.
* `Camera`, `PhotoCamera`, and `QRCodeScanner` are now
  `@unchecked Sendable` so they can be captured in `@Sendable`
  `sessionQueue.async { … }` closures. Public mutable
  properties (`cameraPosition`, `deviceType`) should still be
  configured before `startSession()` is called.

**Other**
* The deprecated `String.trimed` alias has been removed. Use
  `String.trimmed` instead.
* `Date+PovioKit` accessors (`year`, `month`, `day`, `startOfWeek`,
  `endOfWeek`, `isToday`, `isYesterday`) gained optional calendar
  injection via new methods (`year(using:)`, `startOfWeek(using:)`,
  …). The existing computed properties continue to work and default
  to `Calendar.autoupdatingCurrent`.
* `AnimatedImage.Coordinator` no longer accepts a dead
  `onAnimationStart` parameter that was silently discarded. No call
  sites outside the library need to change; the initializer is
  internal.
* SwiftUI `ScrollOffsetPreferenceKey.defaultValue` was changed from
  `static var` to `static let` to silence Swift 6 strict-concurrency
  diagnostics.
* The duplicate `Tests/Tests/Utilities/InAppPurchase 2/` directory (which
  contained tautological error-enum tests) has been removed.
* Several empty directories (`Sources/Utilities/Retry`, `Timeout`,
  `Keychain`, `TaskCoalescer`, `Clock` and their test counterparts)
  have been removed. They did not contain any source files.
* **`NSWindow.takeScreenshot()` (AppKit)** is now part of the public
  API and has been re-implemented on top of `cacheDisplay(in:to:)`
  instead of the deprecated `CGWindowListCreateImage`. Two behaviour
  changes flow from this:
  * The method now captures the window's own content view only, at the
    content view's pixel bounds. Anything drawn *on top* of the window
    by other processes, as well as transparent regions that used to
    sample the desktop behind the window, are no longer included.
  * It no longer mutates the window (`aspectRatio`, `alphaValue`,
    `backgroundColor` are left alone) and no longer requires a
    ScreenCaptureKit / screen-recording entitlement.
  Callers that relied on the previous "sample the screen rect under
  the window" behaviour must drop down to `SCScreenshotManager`
  (ScreenCaptureKit) or `CGWindowListCreateImage` directly.

### Migration from versions < 6.3.0
* [Async] `PovioKitAsync` was significantly expanded with:
  * `AsyncDebounceSequence` (`debounce`) for bursty input control.
  * Retry improvements: `shouldRetry` predicate and jitter support in `AsyncRetryPolicy`.
  * `race` helpers for first-completed operation semantics.
  * `AsyncSemaphore` for bounded async concurrency.
  * `TaskCoalescer` for deduplicating in-flight keyed work.
  * `AsyncTickerSequence` for interval-based async ticks.
* [Async] Existing `retry` calls remain source-compatible. New `shouldRetry` parameter defaults to retrying all errors.

### Migration from versions < 6.2.0
* [Package] Added a separate `PovioKitAppKit` product. If you need AppKit APIs, include this product in your package selection.
* [Core] `Kingfisher` is no longer a transitive dependency of `PovioKitCore`.
* [UI] Platform-specific extensions are now grouped in their dedicated UI modules. If you used UIKit, SwiftUI, or AppKit extensions via `PovioKitCore`, import `PovioKitUIKit`, `PovioKitSwiftUI`, or `PovioKitAppKit` respectively.

### Migration from versions < 6.0.0
* We dropped support for iOS 13, 14 and 15. Supported versions are 16+.
* We dropped support for macOS 12. Supported versions are 13+.
* [Networking] In order to continue using PovioKitNetworking, you'll need to install it as a [separate dependency](https://github.com/povio/PovioKitNetworking).
* [PromiseKit] In order to continue using PovioKitPromise, you'll need to install it as a [separate dependency](https://github.com/povio/PovioKitNetworking).

### Migration from versions < 5.0.0
* [UI] Removed `ActionButton`, `ProfileImageView`.

### Migration from versions < 4.0.0
* [Core] If you have used any utilities referencing to PovioKitCore package, you'll need to replace it. They've been moved to PovioKitUtilities.
* [UI] PovioKitUI package has been replaced by PovioKitUIKit and/or PovioKitSwiftUI. Replace depending on the type of UI code you were depending on.

### Migration from versions < 3.0.0
* [Auth] All Auth products are removed from the PovioKit package and effectively moved to a standalone repo https://github.com/povio/PovioKitAuth. In order to continue using Auth products, install the new `PovioKitAuth` package from the given repo URL.

### Migration from versions < 2.3.0
* [Core] The main package was renamed from `PovioKit` to `PovioKitCore`. You'll need to make a few changes in order to make this work:
  * Remove library `PovioKit` under "Frameworks, Libraries, and Embedded Content" in Xcode and add a `PovioKitCore`.
  * Replace all `import PovioKit` with `import PovioKitCore` in code.
* [Core] Deprecated DataSource protocols and SignInWithApple utility have been removed.

### Migration from versions < 2.2.0
* [Core] Deprecated DataSource protocols and SignInWithApple utility have been removed.

### Migration from versions < 2.0.0
* [Networking] File `OAuthRequestInterceptor` has been completely removed due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. See the networking package documentation at https://github.com/povio/PovioKitNetworking for migration details. Deprecated methods have also been removed.
* [Package] The minimum supported version of iOS is 13. If you still support iOS 12, please evaluate this update.
* [Core] DataSource protocols have been deprecated in favor or diffable data source.
* [UI] Removed deprecated methods.

### Migration from versions < 1.4.1
* [Networking] File `OAuthRequestInterceptor` has been deprecated due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. See https://github.com/povio/PovioKitNetworking for current guidance.

### Migration from versions < 1.4.0
* [UI] New product `PovioKitUI` is introduced. In order to use it, please re-install dependency and select it from product selection list.
* [Networking] Method `asJson` was marked as deprecated. Please stop using it soon.
* [PromiseKit] Removed deprecated methods.

### Migrating from versions < 1.3.1
* [Networking] OAuthStorage protocol now accepts `OAuthContainer` only instead of separate values for `accessToken` and `refreshToken`. Change your implementation accordingly.

### Migrating from versions < 1.3.0
* [PromiseKit] Changes required due to deprecated methods. You'll need to rename them in order to avoid warnings. `chain` was renamed to `flatMap`, `observe` was renamed to `finally`, `onFailure` was renamed to `catch`, `chainError` was renamed to `flatMapError`, `onSuccess` was renamed to `then`.
