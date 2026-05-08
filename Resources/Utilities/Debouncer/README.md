# Debouncer

Closure-based debouncer with configurable leading / trailing behaviour. Built
on Swift Concurrency — uses `Task.sleep(for:)` internally, so pending jobs
participate in cooperative cancellation and there is no per-instance
`DispatchQueue`.

For debouncing `AsyncSequence` values, see `AsyncSequence.debounce(clock:delayBetweenTasks:)`
in the `PovioKitAsync` module instead; `Debouncer` is intended for discrete
events such as keystrokes, button taps, or API calls.

## Behaviours

| Behaviour              | When does the closure fire?                                                         |
| ---------------------- | ----------------------------------------------------------------------------------- |
| `.trailing` (default)  | Once `delay` has elapsed without any further `execute(_:)` call. Last call wins.    |
| `.leading`             | On the first call in a quiescent window. Further calls inside the window are dropped.|
| `.leadingAndTrailing`  | On the leading edge *and* once more at the end of the window (last value wins).     |

## Usage

```swift
final class SearchWorker {
  private let debouncer = Debouncer(delay: .milliseconds(350))

  func search(query: String) {
    debouncer.execute {
      // Runs once the user stops typing for 350 ms.
      Task { @MainActor in
        await self.performSearch(query: query)
      }
    }
  }
}
```

### Main-actor work

Submitted closures are `@Sendable` and may run on any executor. If you need
the work to execute on the main actor, wrap it explicitly:

```swift
debouncer.execute {
  Task { @MainActor in updateUI() }
}
```

### Cancelling

```swift
debouncer.cancel()
```

Drops the pending trailing closure (if any) and resets the cooldown window.
Cancellation of the parent task also propagates through the internal sleep.

## Source code

You can find source code [here](/Sources/Utilities/Debouncer/Debouncer.swift).
