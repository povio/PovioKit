# MediaPlayer

Domain-focused wrappers around `AVPlayer` for audio / video playback. The
types in this module use *composition* instead of subclassing `AVPlayer`,
so callers interact with a narrow, purposeful API and pass the exposed
`AVPlayer` to `AVPlayerLayer` or `AVPlayerViewController` when they need
to render content.

## Types

- **`MediaPlayer`** — wraps an `AVPlayer`, adds a state machine,
  a configurable playback interval, looping, and a `MediaPlayerDelegate`
  for buffering / progress / state-change callbacks. `@MainActor`
  isolated.
- **`AudioPlayer`** — wraps a `MediaPlayer` and adds playlist
  navigation (`selectAudio(stream:)`, `playNext()`, `playPrevious()`)
  on top of a `MediaStream` sequence. Reach into `audioPlayer.mediaPlayer`
  for fine-grained playback controls.
- **`MediaStream`** — `Sendable` protocol describing a playable source
  (`id`, `title`, `url`). `GenericAudioStream` is a ready-made
  implementation.

## Usage

```swift
@MainActor
final class PodcastScreen {
  let audioPlayer: AudioPlayer

  init(episodes: [GenericAudioStream]) {
    audioPlayer = AudioPlayer(streams: episodes)
    audioPlayer.delegate = self
  }

  func start() {
    audioPlayer.play()
  }

  /// Hand the underlying `AVPlayer` to an AVKit view.
  func makeVideoView() -> AVPlayerViewController {
    let controller = AVPlayerViewController()
    controller.player = audioPlayer.mediaPlayer.avPlayer
    return controller
  }
}
```

## Source code

- [MediaPlayer](/Sources/Utilities/MediaPlayer/MediaPlayer.swift)
- [AudioPlayer](/Sources/Utilities/MediaPlayer/AudioPlayer.swift)
- [MediaPlayer+Models](/Sources/Utilities/MediaPlayer/MediaPlayer+Models.swift)
- [MediaStream](/Sources/Utilities/MediaPlayer/MediaStream.swift)
