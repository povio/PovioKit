//
//  AsyncThrottleSequence.swift
//  PovioKit
//
//  Created by Toni K. Turk on 22/08/2023.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

/// `AsyncThrottleSequence` is a wrapper around an `AsyncSequence` that introduces a delay between tasks to control the rate at which elements are emitted.
///
/// This struct is available on iOS 16.0 and later.
/// 
/// This is an _async/await_ implementation of `Throttler`.
/// 
/// ## Example:
/// 
///   - **Step 1:** Create an async sequence type which performs the asynchronous operation that you want to throttle:
///   
///       struct SearchAsyncSequence: AsyncSequence {
///         typealias Element = PostsAsyncIterator.Element
///
///         func makeAsyncIterator() -> SearchAsyncSequence {
///           .init()
///         }
///       }
///       
///       struct PostsAsyncIterator: AsyncIteratorProtocol {
///         typealias Element = [Item]
///         
///         func next() async throws -> Element? {
///            try await callSearchAPI(...)
///         // ^~~~~~~~~~~~~^ operation, which will be throttled
///         }
///       }
///   
///   - **Step 2:** Use the decorator to create a throttled async sequence, and use it to perform operations:
///   
///       class ViewModel: ObservableObject {
///         ...
///         private var throttledSearch = SearchAsyncSequence()
///           .throttle(
///             clock: .suspending,
///             delayBetweenTasks: .miliseconds(600)
///           )
///           .makeAsyncIterator()
///         ...
///         
///         @MainActor
///         func search() {
///           Task {
///             guard let results = try await throttledSearch.next() else { return }
///             // ... 
///           }           
///         }
///       }
///
/// ## Parameters:
///   - BaseSequence: The type of the underlying `AsyncSequence`.
///   - C: The type of the `Clock` used to measure the delay between tasks.
public struct AsyncThrottleSequence<BaseSequence: AsyncSequence, C: Clock> {
  let baseSequence: BaseSequence
  let clock: C
  let delayBetweenTasks: C.Duration
  
  /// Initializes a new `AsyncThrottleSequence` instance.
  ///
  /// - Parameters:
  ///   - baseSequence: The underlying `AsyncSequence` to be throttled.
  ///   - clock: The `Clock` used to measure the delay between tasks.
  ///   - delayBetweenTasks: The duration of the delay between tasks.
  public init(
    _ baseSequence: BaseSequence, 
    clock: C,
    delayBetweenTasks: C.Duration
  ) {
    self.baseSequence = baseSequence
    self.clock = clock
    self.delayBetweenTasks = delayBetweenTasks
  }
}

/// An extension that makes `AsyncThrottleSequence` conform to `AsyncSequence` when `C.Duration` is equal to `Duration`.
extension AsyncThrottleSequence: AsyncSequence where C.Duration == Duration {
  public typealias Element = BaseSequence.Element
  
  /// An iterator that conforms to `AsyncIteratorProtocol` and is used to iterate over the elements of the `AsyncThrottleSequence`.
  public class Iterator: AsyncIteratorProtocol {
    var baseIterator: BaseSequence.AsyncIterator
    var taskInExecution: Task<Element?, Error>?
    let clock: C
    let delayBetweenTasks: C.Duration
    let lock = NSLock()
    
    /// Initializes a new `Iterator` instance.
    ///
    /// - Parameters:
    ///   - baseIterator: The iterator of the underlying `AsyncSequence`.
    ///   - clock: The `Clock` used to measure the delay between tasks.
    ///   - delayBetweenTasks: The duration of the delay between tasks.
    init(
      baseIterator: BaseSequence.AsyncIterator, 
      clock: C,
      delayBetweenTasks: C.Duration
    ) {
      self.baseIterator = baseIterator
      self.clock = clock
      self.delayBetweenTasks = delayBetweenTasks
    }
    
    /// Returns the next element in the sequence, or `nil` if there are no more elements.
    ///
    /// - Throws: An error if the underlying `AsyncSequence` throws an error.
    /// - Returns: The next element in the sequence, or `nil` if there are no more elements.
    public func next() async throws -> Element? {
      let task = lock.withLock {
        taskInExecution?.cancel()
        taskInExecution = nil
        let task = Task {
          try await Task.sleep(
            until: clock.now.advanced(by: delayBetweenTasks),
            clock: clock
          )
          let result = try await baseIterator.next()
          try Task.checkCancellation()
          return result
        }
        taskInExecution = task
        return task
      }
      do {
        return try await task.value
      } catch {
        if error is CancellationError {
          return nil
        }
        throw error
      }
    } 
  }
  
  /// Creates a new iterator for the `AsyncThrottleSequence`.
  ///
  /// - Returns: An iterator that can be used to iterate over the elements of the `AsyncThrottleSequence`.
  public func makeAsyncIterator() -> Iterator {
    .init(
      baseIterator: baseSequence.makeAsyncIterator(), 
      clock: clock,
      delayBetweenTasks: delayBetweenTasks
    )
  }
}

public extension AsyncSequence {
  func throttle<C: Clock>(
    clock: C,
    delayBetweenTasks: C.Duration
  ) -> AsyncThrottleSequence<Self, C> {
    .init(
      self, 
      clock: clock, 
      delayBetweenTasks: delayBetweenTasks
    )
  }
}
