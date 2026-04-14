## Migration Guides

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
