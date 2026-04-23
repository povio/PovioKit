# RemoteImage

A SwiftUI view that asynchronously loads and displays a remote image.
Backed by [Kingfisher](https://github.com/onevcat/Kingfisher)'s `KFImage`
for memory / disk caching, fade transitions, and processor chaining.

By default the image is `.resizable()` and uses `.scaledToFill()` so it
participates naturally in the parent layout — style it further with
SwiftUI modifiers as needed.

## Basic usage

```swift
RemoteImage(url: URL(string: "https://example.com/hero.jpg"))
  .frame(height: 200)
  .clipped()
```

Passing `nil` as the URL renders the placeholder (or nothing if no
placeholder is configured).

## Placeholder

```swift
RemoteImage(url: url, animated: true)
  .placeholder {
    Color.gray.opacity(0.2)
      .overlay(ProgressView())
  }
```

`animated: true` fades the image in over 0.25s when it loads.

## Success / failure callbacks

```swift
RemoteImage(url: url)
  .onSuccess { result in
    print("Image loaded from: \(result.cacheType)")
  }
  .onFailure { error in
    print("Failed to load: \(error)")
  }
```

## Image processors

Any Kingfisher `ImageProcessor` works. Common ones include
`DownsamplingImageProcessor`, `RoundCornerImageProcessor`,
`BlurImageProcessor`, and PovioKit's bundled `JPEGImageProcessor` /
`HEICImageProcessor`.

### Downsampling

```swift
let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))

RemoteImage(url: url)
  .processor(processor)
```

### Downsample then re-encode as JPEG

```swift
let processor =
    DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
    |> JPEGImageProcessor(compressionQuality: 0.8)

RemoteImage(url: url)
  .processor(processor)
```

### Downsample then re-encode as HEIC (best compression)

```swift
let processor =
    DownsamplingImageProcessor(size: CGSize(width: 1200, height: 600))
    |> HEICImageProcessor(compressionQuality: 0.8)

RemoteImage(url: url)
  .processor(processor)
```

## Source code

- [RemoteImage](/Sources/UI/SwiftUI/Views/RemoteImage/RemoteImage.swift)
- [JPEGImageProcessor](/Sources/UI/SwiftUI/Views/RemoteImage/JPEGImageProcessor.swift)
- [HEICImageProcessor](/Sources/UI/SwiftUI/Views/RemoteImage/HEICImageProcessor.swift)
