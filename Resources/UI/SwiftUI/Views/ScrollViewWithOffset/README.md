# ScrollViewWithOffset

A drop-in replacement for SwiftUI's `ScrollView` that reports its current
content offset as it scrolls. Useful for driving parallax headers,
shrinking navigation bars, lazy "load more" triggers, or any UI that
needs to react to scroll position.

The implementation is a thin wrapper around `ScrollView` that uses a
`PreferenceKey` to track the origin of the content inside a named
coordinate space — no `UIScrollView` bridging or `GeometryReader`
gymnastics at the call site.

## Basic usage

```swift
struct Feed: View {
  @State private var offset: CGPoint = .zero

  var body: some View {
    ScrollViewWithOffset(onScroll: { offset = $0 }) {
      LazyVStack {
        ForEach(posts) { post in
          PostRow(post: post)
        }
      }
    }
    .overlay(alignment: .top) {
      Text("y: \(Int(offset.y))").padding()
    }
  }
}
```

The `onScroll` closure receives a `CGPoint` — the content origin in the
scroll view's coordinate space. When the user scrolls down, `y` becomes
progressively negative.

## Customising axes and indicators

```swift
ScrollViewWithOffset(
  .horizontal,
  showsIndicators: false,
  onScroll: handleScroll
) {
  HStack(spacing: 16) { ... }
}
```

Defaults: `.vertical`, `showsIndicators: true`, `onScroll: nil`.

## Parallax header example

```swift
ScrollViewWithOffset(onScroll: { offset = $0 }) {
  VStack(spacing: 0) {
    Image("hero")
      .resizable()
      .scaledToFill()
      .frame(height: 260)
      .offset(y: max(0, -offset.y) * 0.5) // slower scroll
      .clipped()

    content
  }
}
```

## Credit

Adapted from [danielsaidi/ScrollKit](https://github.com/danielsaidi/ScrollKit).

## Source code

You can find source code [here](/Sources/UI/SwiftUI/Views/ScrollViewWithOffset/ScrollViewWithOffset.swift).
