//
//  Collection+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension Collection {
  /// Returns the element at the specified `index` if it is within bounds, otherwise `nil`.
  /// Returns the element at the specified `index` if it is within bounds, otherwise `nil`.
  ///
  /// This subscript safely accesses an element in the collection at the given index. If the index is out of bounds, it returns `nil` instead of causing a runtime error.
  ///
  /// - Parameter index: The index of the element to retrieve.
  /// - Returns: The element at the specified index if within bounds, otherwise `nil`.
  ///
  /// ## Example:
  /// ```swift
  /// let array = [1, 2, 3, 4]
  /// let element = array[safe: 2] // returns 3
  /// let outOfBounds = array[safe: 10] // returns nil
  /// ```
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

public extension Collection {
  /// Returns the count of elements in the collection that satisfy the given predicate.
  /// Check for [Reference](https://forums.swift.org/t/refresh-review-se-0220-count-where/66235/4).
  ///
  /// This method applies the provided `predicate` closure to each element in the collection and counts how many elements satisfy the condition.
  ///
  /// - Parameter predicate: A closure that takes an element of the collection and returns a boolean value indicating whether the element satisfies the condition.
  /// - Returns: The count of elements that satisfy the predicate.
  /// - Throws: This method may throw an error if the `predicate` closure throws an error.
  ///
  /// ## Example
  /// ```swift
  /// let numbers = [1, 2, 3, 4, 5]
  /// let countEven = numbers.count { $0 % 2 == 0 } // counts how many numbers are even
  /// Logger.debug(countEven) // output: 2 (since 2 and 4 are even)
  /// ```
  @inlinable
  func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
    try reduce(0) { n, element in
      if try predicate(element) { 
        n + 1 
      } else { 
        n 
      }
    }
  }
  
  /// Groups the elements of the collection based on extracted date components and returns a dictionary where keys are dates and values are arrays of elements that correspond to those dates.
  ///
  /// This method extracts the date components from each element (using the `extractDate` closure), then groups the elements based on those components.
  /// The default date components used for grouping are `.year`, `.month`, and `.day`. The grouping is performed using the provided calendar (or `Calendar.current` by default).
  ///
  /// - Parameters:
  ///   - extractDate: A closure that extracts a `Date` from each element in the collection.
  ///   - dateComponents: A set of calendar components used to group the dates. The default is `.year`, `.month`, and `.day`.
  ///   - calendar: The calendar used to extract and group the date components. The default is `Calendar.current`.
  /// - Returns: A dictionary where the keys are `Date` objects representing the grouped date components,
  ///           and the values are arrays of elements that correspond to each grouped date.
  ///
  /// ## Example
  /// ```swift
  /// struct Event {
  ///   var name: String
  ///   var date: Date
  /// }
  /// let events = [
  ///   Event(name: "New Year Party", date: DateFormatter().date(from: "2024-01-01")!),
  ///   Event(name: "New Year's Morning Run", date: dateFormatter.date(from: "2024-01-01")!),
  ///   Event(name: "Spring Festival", date: DateFormatter().date(from: "2024-03-20")!),
  ///   Event(name: "Summer Beach Party", date: DateFormatter().date(from: "2024-06-21")!),
  ///   Event(name: "Christmas Party", date: dateFormatter.date(from: "2024-12-25")!),
  ///   Event(name: "Christmas Eve Dinner", date: dateFormatter.date(from: "2024-12-25")!),
  ///   Event(name: "New Year's Eve", date: DateFormatter().date(from: "2024-12-31")!)
  /// ]
  /// let groupedEvents = events.grouped(
  ///   extractDate: { $0.date },
  ///   by: [.year, .month],
  ///   calendar: Calendar.current
  /// )
  /// // Print the grouped events by year and month
  /// for (date, eventsInMonth) in groupedEvents {
  ///   let monthString = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .none)
  ///   Logger.debug("Events in \(monthString):")
  ///   for event in eventsInMonth {
  ///     Logger.debug(" - \(event.name) on \(dateFormatter.string(from: event.date))")
  ///   }
  /// }
  ///
  /// /* Output:
  /// Events in 2024-01:
  ///  - New Year Party on 2024-01-01
  ///  - New Year's Morning Run on 2024-01-01
  /// Events in 2024-03:
  ///  - Spring Festival on 2024-03-20
  /// Events in 2024-06:
  ///  - Summer Beach Party on 2024-06-21
  /// Events in 2024-12:
  ///  - Christmas Party on 2024-12-25
  ///  - Christmas Eve Dinner on 2024-12-25
  ///  - New Year's Eve on 2024-12-31
  /// */
  /// ```
  func grouped(
    extractDate: (Element) -> Date,
    by dateComponents: Set<Calendar.Component> = [.year, .month, .day],
    calendar: Calendar = Calendar.current
  ) -> [Date: [Element]] {
    .init(
      grouping: self,
      by: {
        let components = calendar.dateComponents(dateComponents, from: extractDate($0))
        let date = calendar.date(from: components) ?? Date()
        return date
      }
    )
  }
}

public extension MutableCollection {
  /// A method to mutate each element of a collection using a provided mutator closure.
  /// This method allows in-place mutation of the elements in the collection by passing a mutator function that modifies each element.
  ///
  /// - Parameter mutator: A closure that takes a reference to each element in the collection (`inout Element`) and performs the mutation.
  /// - Throws: It can throw an error if the `mutator` closure itself throws an error during the mutation process.
  ///
  /// ## Example
  /// ```swift
  /// var numbers = [1, 2, 3, 4, 5]
  ///
  /// // define a mutator closure that increments each number by 1
  /// let increment: (inout Int) throws -> Void = { number in
  ///   number += 1
  /// }
  /// do {
  ///
  /// // mutate each number in the array by applying the increment closure
  /// try numbers.mutateEach(increment)
  ///   Logger.debug(numbers)  // Output: [2, 3, 4, 5, 6]
  /// } catch {
  ///   Logger.error("Error: \(error)")
  /// }
  /// ```
  mutating func mutateEach(_ mutator: (inout Element) throws -> Void) rethrows {
    var idx = startIndex
    while idx != endIndex {
      try mutator(&self[idx])
      formIndex(after: &idx)
    }
  }
}

extension MutableCollection where Self: RandomAccessCollection {
  /// Updates the element at the specified index with a new value.
  ///
  /// - Parameters:
  ///   - item: The new value to set at the specified index.
  ///   - index: The index of the element to update.
  /// - Returns: A boolean value indicating whether the update was successful. Returns `true` if the index is valid and the update was performed; otherwise, returns `false`.
  ///
  /// ## Example
  /// ```
  /// var array = [1, 2, 3, 4]
  /// let success = array.update(10, at: 2)
  /// // array is now [1, 2, 10, 4]
  /// // success is true
  ///
  /// let failure = array.update(10, at: 10)
  /// // array remains [1, 2, 10, 4]
  /// // failure is false
  /// ```
  @discardableResult
  mutating func update(_ item: Element, at index: Index) -> Bool {
    guard indices.contains(index) else { return false }
    self[index] = item
    return true
  }
}

public extension RandomAccessCollection {
  /// Splits the collection into chunks of a specified size.
  ///
  /// - Parameter size: The size of each chunk. Each chunk will contain up to `size` elements.
  /// - Returns: An array of arrays, where each inner array is a chunk of the original array.
  ///
  /// - Note: If the array's size is not a perfect multiple of `size`, the last chunk will contain the remaining elements.
  ///
  /// ## Example
  /// ```
  /// let array = [1, 2, 3, 4, 5, 6, 7]
  /// let chunks = array.chunked(into: 3)
  /// for chunk in collectionChunks {
  ///   Logger.debug(chunk) // Output: [1, 2, 3], [4, 5, 6], [7]
  /// }
  /// ```
  func chunked(into size: Int) -> [SubSequence] {
    guard size > 0 else { return [] }
    var result: [SubSequence] = []
    var start = startIndex
    while start != endIndex {
      let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
      result.append(self[start..<end])
      start = end
    }
    return result
  }
}
