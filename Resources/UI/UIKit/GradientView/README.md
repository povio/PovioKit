# GradientView

A `UIView` subclass providing a simple interface for managing a
`CAGradientLayer` background. Use it as-is, subclass it to back a
bespoke view, or add an instance as a subview. Color changes can be
animated.

## Usage

### Basic

```swift
let gradient = GradientView(colors: [.systemBlue, .systemPurple])
gradient.setGradient(startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1))
view.addSubview(gradient)
```

### Locations

```swift
gradient.setLocations(locations: [0, 0.6, 1])
```

### Animated color change

```swift
gradient.setGradientColors(
  [.systemPink, .systemOrange],
  locations: [0, 1],
  animated: true,
  animationDuration: 0.4
)
```

### Show / hide

```swift
gradient.isShowingGradient = false  // hide the gradient layer without removing the view
```

### Using an existing layer

If you've already configured a `CAGradientLayer` elsewhere, pass it in
directly:

```swift
let layer = CAGradientLayer()
layer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
let view = GradientView(layer: layer)
```

## Source code

You can find source code [here](/Sources/UI/UIKit/Views/GradientView/GradientView.swift).
