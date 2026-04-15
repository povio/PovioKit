# PovioKit: Core

Core package includes essentials needed for the development and for other packages.

The module is intentionally foundation-first and serves as the base dependency for other PovioKit products.

### Essentials
| Components |
| :--- |
| [AppInfo](/Sources/Core/AppInfo.swift) |
| [Logger](Logger) |


### Extensions

| Foundation | MapKit | Other |
| :--- | :--- | :--- |
| [Collection](/Sources/Core/Extensions/Foundation/Collection+PovioKit.swift) | [MKAnnotationView](/Sources/Core/Extensions/MapKit/MKAnnotationView+PovioKit.swift) | [SKStoreReviewController](/Sources/Core/Extensions/Other/SKStoreReviewController+PovioKit.swift) |
| [Data](/Sources/Core/Extensions/Foundation/Data+PovioKit.swift) | [MKCircle](/Sources/Core/Extensions/MapKit/MKCircle+PovioKit.swift) | |
| [Date](/Sources/Core/Extensions/Foundation/Date+PovioKit.swift) | [MKMapView](/Sources/Core/Extensions/MapKit/MKMapView+PovioKit.swift) | |
| [DateFormatter](/Sources/Core/Extensions/Foundation/DateFormatter+PovioKit.swift) | [MKPolygon](/Sources/Core/Extensions/MapKit/MKPolygon+PovioKit.swift) | |
| [DecodableDictionary](/Sources/Core/Extensions/Foundation/DecodableDictionary+PovioKit.swift) | | |
| [DispatchTimeInterval](/Sources/Core/Extensions/Foundation/DispatchTimeInterval+PovioKit.swift) | | |
| [Double](/Sources/Core/Extensions/Foundation/Double+PovioKit.swift) | | |
| [Encodable](/Sources/Core/Extensions/Foundation/Encodable+PovioKit.swift) | | |
| [NotificationCenter](/Sources/Core/Extensions/Foundation/NotificationCenter+PovioKit.swift) ([Usage](Extensions/NotificationCenter+PovioKit.md)) | | |
| [Optional](/Sources/Core/Extensions/Foundation/Optional+PovioKit.swift) | | |
| [Result](/Sources/Core/Extensions/Foundation/Result+PovioKit.swift) | | |
| [String](/Sources/Core/Extensions/Foundation/String+PovioKit.swift) | | |
| [URL](/Sources/Core/Extensions/Foundation/URL+PovioKit.swift) | | |

### Notes
- Some app lifecycle helpers are only available when UIKit can be imported.
- Notification helpers support `post`, `observe`, and Combine `publisher` workflows.
