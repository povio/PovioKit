# DispatchTimer

A small, thread-safe `NSTimer` replacement built on `DispatchSourceTimer`.
Supports repeating and one-shot timers, and is safe to schedule / stop
across threads.

```swift
let timer = DispatchTimer()
timer.schedule(interval: .seconds(10), repeating: true, on: .main) { [weak self] in
  self?.refreshProgress()
}

timer.stop()   // also happens automatically on deinit
```

There's also a fire-and-forget static variant that returns the new
timer:

```swift
let timer = DispatchTimer.scheduled(
  interval: .seconds(10),
  repeating: false,
  on: .main
) { timer in
  // one-shot callback — `timer` is already stopped by the time we're in here.
}
```

See [DispatchTimer.swift](/Sources/Utilities/DispatchTimer/DispatchTimer.swift)
for the full API (`isActive`, etc.).
