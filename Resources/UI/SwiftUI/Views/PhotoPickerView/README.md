# PhotoPickerView

A SwiftUI wrapper around `UIImagePickerController` that lets you pick an
image from the photo library or capture one with the camera. iOS only.

`PhotoPickerView` is almost always used through the companion
[`photoPicker`](../../View%20Modifiers/PhotoPickerModifier.swift)
view modifier, which presents a confirmation dialog letting the user
pick a source and then shows the appropriate picker. You can also use
`PhotoPickerView` directly if you don't need the confirmation dialog.

## Combined usage (recommended)

```swift
struct ProfileScreen: View {
  @State private var presentPicker = false
  @State private var avatar: UIImage?

  var body: some View {
    Button("Change photo") { presentPicker = true }
      .photoPicker(
        present: $presentPicker,
        configuration: .init(
          takePhoto: "Take a Photo",
          chooseFromLibrary: "Choose from Library",
          removePhoto: avatar == nil ? nil : "Remove Photo"
        ),
        removeHandler: { avatar = nil },
        imageHandler: { image in avatar = image }
      )
  }
}
```

`removeHandler` is optional — pass `nil` and the "Remove Photo" button
is omitted. If you also pass `configuration.removePhoto = nil`, the
button is suppressed even when a handler is set.

## Standalone usage

If you want to skip the confirmation dialog and go straight to a
specific source, present `PhotoPickerView` yourself:

```swift
struct CameraScreen: View {
  @State private var presentCamera = false
  @State private var capture: UIImage?

  var body: some View {
    Button("Open camera") { presentCamera = true }
      .fullScreenCover(isPresented: $presentCamera) {
        PhotoPickerView(sourceType: .camera) { image in
          capture = image
        }
        .ignoresSafeArea()
      }
  }
}
```

Supported source types are `.camera` and `.photoLibrary`. The picker
dismisses itself and then forwards the selected `UIImage` through
`onComplete`; cancellation dismisses without calling the handler.

## Source code

- [PhotoPickerView](/Sources/UI/SwiftUI/Views/PhotoPickerView/PhotoPickerView.swift)
- [PhotoPickerModifier](/Sources/UI/SwiftUI/View%20Modifiers/PhotoPickerModifier.swift)
