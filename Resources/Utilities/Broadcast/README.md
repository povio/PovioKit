# Broadcast

Implement `Observer / Listener` pattern with ease.

## Usage

In iOS, we often use the `delegate` pattern to delegate some responsibilites, or to notify objects of some events. But sometimes we don't want to limit ourselves to only one listener. Let's see an example of this in action:

> `Broadcast<T>` stores observers as **weak** references, so callers
> don't need to explicitly remove themselves on deinit to avoid retain
> cycles. `T` must be a class-bound type (a concrete class, or a
> protocol declared with `: AnyObject`) — value-type observers would
> appear to register and then be pruned immediately by the weak
> storage.

```swift
protocol AppEventObserver: AnyObject {
  func keyboardWillShow(animationDuration: CGFloat, keyboardSize: CGSize)
  func keyboardWillHide(animationDuration: CGFloat, keyboardSize: CGSize)
}

final class KeyboardBroadcast {
  let appEvents = Broadcast<AppEventObserver>()

  init() {
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil
    ) { [appEvents] _ in
      appEvents.invoke {
        $0.keyboardWillShow(animationDuration: ..., keyboardSize: CGSize(...))
      }
    }
    NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil
    ) { [appEvents] _ in
      appEvents.invoke {
        $0.keyboardWillHide(animationDuration: ..., keyboardSize: CGSize(...))
      }
    }
  }
}
```

Subscribing to keyboard notifications is as easy as:

```swift
let keyboardBroadcast = KeyboardBroadcast()

class ViewController: UIViewController, AppEventObserver {
  override func viewDidLoad() {
    super.viewDidLoad()
    keyboardBroadcast.appEvents.add(observer: self)
  }

  func keyboardWillShow(animationDuration: CGFloat, keyboardSize: CGSize) { ... }
  func keyboardWillHide(animationDuration: CGFloat, keyboardSize: CGSize) { ... }
}
```

To remove an observer explicitly (normally unnecessary, since the
broadcast holds weak references):

```swift
keyboardBroadcast.appEvents.remove(observer: self)
```

You can also dispatch invocations onto a queue — handy when observers
only run main-thread safe work:

```swift
appEvents.invoke(on: .main) { $0.keyboardWillShow(...) }
```

## Source code
You can find source code [here](/Sources/Utilities/Broadcast/Broadcast.swift).
