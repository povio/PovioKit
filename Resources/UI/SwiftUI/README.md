# PovioKit: SwiftUI

A package including components to help you out developing for SwiftUI framework.

### Components

| Views | Platform | |
| :--- | :--- | :--- |
| [LinearProgressStyle](/Sources/UI/SwiftUI/Views/LinearProgressStyle/LinearProgressStyle.swift) | iOS | A custom linear ProgressView style |
| [MaterialBlurView](/Sources/UI/SwiftUI/Views/MaterialBlurView/MaterialBlurView.swift) | all | Material blur effects view |
| [PhotoPickerView](Views/PhotoPickerView) | iOS | Photo and Camera picker view, used alone or via the `photoPicker` modifier. |
| [RemoteImage](Views/RemoteImage) | all | Fetching remote images using Kingfisher, with placeholder / processor / callback support. |
| [AnimatedImage](/Sources/UI/SwiftUI/Views/AnimatedImage/AnimatedImage.swift) | all | Fetching remote or local GIF images using Kingfisher |
| [ScrollViewWithOffset](Views/ScrollViewWithOffset) | all | `ScrollView` that exposes offset as we scroll. |
| [SimpleColorPicker](/Sources/UI/SwiftUI/Views/SimpleColorPicker/SimpleColorPicker.swift) | macOS | Wrapper for NSColorWell component |

| View Modifiers | Platform | |
| :--- | :--- | :--- |
| [DeviceShakeViewModifier](/Sources/UI/SwiftUI/View%20Modifiers/DeviceShakeViewModifier.swift) | iOS | Adds an `.onShake { … }` modifier that fires when the app posts `AppNotification.deviceDidShake`. |
| [MaterialBlurBackgroundModifier](/Sources/UI/SwiftUI/View%20Modifiers/MaterialBlurBackgroundModifier.swift) | all | Material blur effects modifier. |
| [MeasureSizeModifier](/Sources/UI/SwiftUI/View%20Modifiers/MeasureSizeModifier.swift) | all | A modifier to return size of the underlying view |
| [OnFirstAppearModifier](/Sources/UI/SwiftUI/View%20Modifiers/OnFirstAppearModifier.swift) | all | Similar to the `OnAppear` modifier, but only runs once per view lifecycle |
| [PhotoPickerModifier](/Sources/UI/SwiftUI/View%20Modifiers/PhotoPickerModifier.swift) | iOS | Easily add photo or camera picker to the view |
| [PinchToZoomModifier](/Sources/UI/SwiftUI/View%20Modifiers/PinchToZoomModifier.swift) | iOS | Pinching and zooming in/out with ease |
| [SquaredModifier](/Sources/UI/SwiftUI/View%20Modifiers/SquaredModifier.swift) | all | Make given view squared. This is mostly used with images to properly keep the aspect ratio |
| [TextFieldLimitModifer](/Sources/UI/SwiftUI/View%20Modifiers/TextFieldLimitModifer.swift) | all | This modifier adds an upper bound text length limitation to the TextField |

| Extensions |
| :--- |
| [AnyTransition](/Sources/UI/SwiftUI/Extensions/AnyTransition+PovioKit.swift) |
| [Color](/Sources/UI/SwiftUI/Extensions/Color+PovioKit.swift) |
| [Text](/Sources/UI/SwiftUI/Extensions/Text+PovioKit.swift) |
| [View](/Sources/UI/SwiftUI/Extensions/View+PovioKit.swift) |

| Image Processors | Platform | |
| :--- | :--- | :--- |
| [HEICImageProcessor](/Sources/UI/SwiftUI/Views/RemoteImage/HEICImageProcessor.swift) | all | Kingfisher processor for HEIC image data. |
| [JPEGImageProcessor](/Sources/UI/SwiftUI/Views/RemoteImage/JPEGImageProcessor.swift) | all | Kingfisher processor for JPEG image data. |
