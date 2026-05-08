# ``PovioKitCore``

Core primitives, extensions, and shared building blocks used across PovioKit modules.

## Overview

`PovioKitCore` contains reusable foundation utilities and low-level helpers intended to stay lightweight and broadly applicable.

This module is intended as the shared base layer for other PovioKit products.

## Main building blocks

- `AppInfo` for app metadata and safe deep-link opening helpers.
- `Logger` for lightweight app-level logging on top of `OSLog`.
- `AppNotification` and `NotificationCenter` convenience APIs for posting, observing, and publishing notifications.
- Foundation extensions for `Collection`, `Date`, `String`, `URL`, and related utility types.

## Platform notes

- Foundation extensions are available on all PovioKitCore-supported platforms.
- Some APIs (for example app lifecycle notifications and StoreKit helpers) require UIKit and are only available where UIKit is present.

## Testing

- Core coverage lives in `Tests/Tests/Core`.
- The test suite includes URL safety, logger behavior, date formatting, and notification helper coverage.
