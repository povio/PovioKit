# Debouncer

Configurable debouncer supporting `leading`, `trailing`, or combined behavior.

## Usage

```swift
final class SearchWorker {
  private let debouncer = Debouncer(
    delay: .milliseconds(350),
    behavior: .trailing
  )
  
  func search(query: String) {
    debouncer.execute {
      // Executes once user stops typing for 350ms.
      self.performSearch(query: query)
    }
  }
  
  private func performSearch(query: String) {
    // perform request
  }
}
```

## Source code
You can find source code [here](/Sources/Utilities/Debouncer/Debouncer.swift).
