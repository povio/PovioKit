# PaddingLabel

A `UILabel` subclass with a configurable `contentInset: UIEdgeInsets`
that's applied to the label's intrinsic content size and draw rect.

```swift
let label = PaddingLabel()
label.contentInset = .init(all: 10)
```

See source for the full API: [PaddingLabel.swift](/Sources/UI/UIKit/Views/PaddingLabel/PaddingLabel.swift).
