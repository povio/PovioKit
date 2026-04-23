# PovioKit: Async

A package that includes async components and tools.

- [Recipes](Recipes.md): practical composition patterns for production workflows.

### Components
| Component | Description |
| :--- | :--- |
| [AsyncDebounceSequence](/Sources/Async/AsyncDebounceSequence.swift) | Caller-driven debounce: each `next()` cancels the prior pending fetch and only proceeds after a quiet period. |
| [AsyncSampleSequence](/Sources/Async/AsyncSampleSequence.swift) | Source-driven sampling: emits at most one element per window, collapsing bursts to the latest. |
| [retry(policy:clock:operation:)](/Sources/Async/AsyncUtilities.swift) | Retries an async operation with configurable attempts and exponential backoff. |
| [withTimeout(_:clock:operation:)](/Sources/Async/AsyncUtilities.swift) | Runs an async operation with a timeout and throws if the deadline is exceeded. |
| [race](/Sources/Async/AsyncUtilities.swift) | Runs multiple operations in parallel and returns the first completed result. |
| [makeAsyncStream](/Sources/Async/AsyncUtilities.swift) | Creates an `AsyncStream` together with its continuation for callback bridging. |
| [makeAsyncThrowingStream](/Sources/Async/AsyncUtilities.swift) | Creates an `AsyncThrowingStream` and continuation pair with typed failure. |
| [AsyncSemaphore](/Sources/Async/AsyncSemaphore.swift) | Limits how many async operations can run at the same time. |
| [TaskCoalescer](/Sources/Async/TaskCoalescer.swift) | Deduplicates in-flight operations by key and shares a single task result. |
| [AsyncTickerSequence](/Sources/Async/AsyncTickerSequence.swift) | Emits periodic ticks at a fixed interval. |

### Examples

#### AsyncDebounceSequence

```swift
let debouncedSearch = SearchAsyncSequence()
  .debounce(clock: .suspending, delayBetweenTasks: .milliseconds(400))
  .makeAsyncIterator()

let result = try await debouncedSearch.next()
```

#### AsyncSampleSequence

```swift
for try await query in userInputSequence.sample(
  clock: .suspending,
  delayBetweenElements: .milliseconds(300)
) {
  try await searchService.search(query: query)
}
```

#### retry(policy:clock:operation:)

```swift
let profile = try await retry(
  policy: .init(
    maxAttempts: 3,
    initialDelay: .milliseconds(200),
    backoffFactor: 2,
    jitter: .milliseconds(50)
  ),
  shouldRetry: { error in
    (error as? URLError)?.code != .userAuthenticationRequired
  }
) {
  try await apiClient.fetchProfile()
}
```

#### withTimeout(_:clock:operation:)

```swift
let data = try await withTimeout(.seconds(2)) {
  try await networkClient.requestData()
}
```

#### race

```swift
let response = try await race(
  { try await cacheClient.read() },
  { try await apiClient.request() }
)
```

#### makeAsyncStream

```swift
let pipe = makeAsyncStream() as AsyncStreamPipe<String>
callbackSource.onEvent = { event in pipe.continuation.yield(event) }

for await event in pipe.stream {
  print(event)
}
```

#### makeAsyncThrowingStream

```swift
let pipe = makeAsyncThrowingStream() as AsyncThrowingStreamPipe<Data>
socket.onMessage = { message in pipe.continuation.yield(message) }
socket.onError = { error in pipe.continuation.finish(throwing: error) }

for try await message in pipe.stream {
  print(message)
}
```

#### AsyncSemaphore

```swift
let semaphore = AsyncSemaphore(value: 3)

try await withThrowingTaskGroup(of: Void.self) { group in
  for imageURL in urls {
    group.addTask {
      try await semaphore.withPermit {
        try await imageClient.download(url: imageURL)
      }
    }
  }
  try await group.waitForAll()
}
```

#### TaskCoalescer

```swift
let coalescer = TaskCoalescer<String, User>()

let user = try await coalescer.value(for: "user_42") {
  try await apiClient.fetchUser(id: "user_42")
}
```

#### AsyncTickerSequence

```swift
let ticker = AsyncTickerSequence(
  clock: ContinuousClock(),
  interval: .seconds(1)
)

var iterator = ticker.makeAsyncIterator()
let firstTick = try await iterator.next()
```
