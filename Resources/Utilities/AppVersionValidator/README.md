# AppVersionValidator

Compare semantic-looking version strings such as `"1.8.4"`, `"2.0"`, or
`"2.0.0.8"`. Useful for gating "you must update" flows, feature flags
tied to a minimum app version, or remote-config thresholds.

## Usage

```swift
let validator = AppVersionValidator()

let ok = try validator.isAppVersion("1.9.0", equalOrHigherThan: "1.8.4")
// ok == true
```

The comparison is **left-to-right, numeric per segment**, with
trailing-zero normalisation:

- `"2.0.0"` compares equal to `"2"` (trailing zeros are equivalent).
- `"2"` is **less than** `"2.0.0.1"` (required has a non-zero extra
  segment).
- Non-numeric segments, empty segments, or an empty input string throw
  `AppVersionValidatorError`.

## Errors

```swift
public enum AppVersionValidatorError: Error, Equatable, Sendable {
  case emptyVersionString
  case invalidVersionComponent(String)
}
```

## Examples

```swift
try validator.isAppVersion("1.8.4", equalOrHigherThan: "1.8.4")  // true
try validator.isAppVersion("2.0.0", equalOrHigherThan: "2")      // true
try validator.isAppVersion("2",     equalOrHigherThan: "2.0.0.8")// false
try validator.isAppVersion("",      equalOrHigherThan: "1.0")    // throws .emptyVersionString
try validator.isAppVersion("1.2a",  equalOrHigherThan: "1.0")    // throws .invalidVersionComponent
```

## Source code

You can find source code [here](/Sources/Utilities/AppVersionValidator/AppVersionValidator.swift).
