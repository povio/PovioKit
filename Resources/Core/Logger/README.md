# Logger

Simple, performant console logger built on top of Apple's [OSLog](https://developer.apple.com/documentation/os/logging)
framework.

## Log levels

`Logger.LogLevel` is an ordered enum; a log call fires only when the
shared logger's `logLevel` is at least as permissive as the call's
level.

| Level   | Ordering |
| :------ | :------- |
| `.none` | 0 (silent — default) |
| `.error`| 1 |
| `.warn` | 2 |
| `.info` | 3 |
| `.debug`| 4 |
| `.all`  | 5 (verbose) |

Change the global level (typically once at app launch) via the
thread-safe shared instance:

```swift
Logger.shared.logLevel = .debug
```

> The default level is `.none`, so messages are dropped until the level
> is raised. Most apps set it to `.debug` on debug builds and leave it
> at `.none` (or `.error`) on release.

## Interface methods

Four static entry points mirror the level enum:

```swift
static func info(_ message: String, params: Logger.Parameters? = nil)
static func debug(_ message: String, params: Logger.Parameters? = nil)
static func warning(_ message: String, params: Logger.Parameters? = nil)
static func error(_ message: String, params: Logger.Parameters? = nil)
```

`Logger.Parameters` is a `typealias` for `[String: Any]` used for
structured key/value metadata alongside the message.

```swift
Logger.debug("Something went wrong", params: ["objectId": 1])
```

## Source code

You can find source code [here](/Sources/Core/Logger/Logger.swift).
