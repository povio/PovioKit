# NotificationCenter+PovioKit

`PovioKitCore` includes generic `NotificationCenter` helpers in
`NotificationCenter+PovioKit.swift`.

For common UIKit events, `PovioKitCore` also provides:

- `AppNotification.onAppResume`
- `AppNotification.onAppPause`
- `AppNotification.onScreenshot`
- `AppNotification.keyboardWillShow`
- `AppNotification.keyboardWillHide`
- `AppNotification.deviceDidShake`

`AppNotification.deviceDidShake` is intentionally app-emitted. PovioKit observes it,
but your app is responsible for posting it when shake is detected.

## 1) Create notifications

Use `AppNotification` as a single entrypoint for both built-in and custom names.

```swift
import Foundation
import UIKit
import PovioKitCore

let signInComplete = AppNotification.named("com.myapp.notification.signInComplete")
let deeplink = AppNotification.named("com.myapp.notification.openDeepLink")
```

## 2) Publish and observe

Use typed helpers for posting, observing, and Combine publishers.

```swift
import Combine

final class SessionObserver {
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter
            .publisher(for: AppNotification.onAppResume)
            .sink { notification in
                print("App resumed: \(notification)")
            }
            .store(in: &cancellables)

        let customNotification = AppNotification.named("com.myapp.notification.signInComplete")
        NotificationCenter.observe(customNotification) { _ in
            print("Sign in complete")
        }
    }
}

NotificationCenter.post(AppNotification.onScreenshot)
```

`Notification.Name` also conforms to `PovioNotificationRepresentable`, so UIKit system
notifications can be used directly:

```swift
NotificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
```

Or use the built-in typed enum:

```swift
NotificationCenter.publisher(for: AppNotification.onAppResume)
NotificationCenter.observe(AppNotification.keyboardWillShow) { _ in
    print("Keyboard will show")
}
```
