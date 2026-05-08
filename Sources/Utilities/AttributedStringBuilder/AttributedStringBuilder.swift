//
//  AttributedStringBuilder.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/// `BuilderCompatible` exists to attach an `AttributedStringBuilder` to UIKit
/// text-carrying views (`UILabel`, `UITextField`). Those views are
/// `@MainActor`-isolated, so the protocol — and by extension the builder —
/// is as well. This avoids crossing isolation boundaries when
/// `BuilderCompatible` conformances are declared on UIKit classes.
@MainActor
public protocol BuilderCompatible: AnyObject {
  var attributedText: NSAttributedString? { get set }
  var text: String? { get }
  var bd: AttributedStringBuilder { get }
}

extension BuilderCompatible {
  public var bd: AttributedStringBuilder { return AttributedStringBuilder(self) }
}

@MainActor
public final class AttributedStringBuilder {
  private let compatible: BuilderCompatible?
  
  public init() {
    self.compatible = nil
  }
  
  public init(_ compatible: BuilderCompatible?) {
    self.compatible = compatible
  }
  
  @discardableResult
  public func apply(on text: String, _ closure: (Builder) -> Void) -> NSAttributedString {
    let builder = Builder(text: text)
    closure(builder)
    let attributedString = builder.create()
    compatible?.attributedText = attributedString
    return attributedString
  }
  
  @discardableResult
  public func apply(_ closure: (Builder) -> Void) -> NSAttributedString {
    let builder = Builder(text: compatible?.text ?? "")
    closure(builder)
    let attributedString = builder.create()
    compatible?.attributedText = attributedString
    return attributedString
  }
}

public final class Builder {
  private enum StringBuilderError: Error {
    case invalidRange
    case substringNotFound
    
    var localizedTitle: String? {
      return "Error"
    }
  }
  
  public let text: String
  private var attributes = [NSAttributedString.Key: Any]()
  private var rangeAttributes = [(NSAttributedString.Key, Any, NSRange)]()
  
  public init(text: String) {
    self.text = text
  }
}

// MARK: - Custom initializers
extension Builder {
  public func create() -> NSAttributedString {
    if rangeAttributes.isEmpty {
      return NSAttributedString(string: text, attributes: attributes)
    }
    return createMutable() as NSAttributedString
  }
  
  public func createMutable() -> NSMutableAttributedString {
    let mutableString = NSMutableAttributedString(string: text, attributes: attributes)
    for (key, value, range) in rangeAttributes {
      mutableString.addAttribute(key, value: value, range: range)
    }
    return mutableString
  }
}

// MARK: - Add Attribute Setters
extension Builder {
  @discardableResult
  public func addAttribute(key: NSAttributedString.Key, object: Any?) -> Builder {
    if let object = object {
      attributes[key] = object
    }
    return self
  }
  
  @discardableResult
  public func addAttribute(key: NSAttributedString.Key, object: Any?, range: NSRange) -> Builder {
    guard validate(range: range) else { return self }
    if let object = object {
      rangeAttributes.append((key, object, range))
    }
    return self
  }
  
  @discardableResult
  public func addAttribute(key: NSAttributedString.Key, object: Any?, substring: String) -> Builder {
    guard let range = text.range(of: substring) else { return self }
    return addAttribute(key: key, object: object, range: NSRange(range, in: text))
  }
}

// MARK: - Other Setters
extension Builder {
  @discardableResult
  public func setFont(_ font: UIFont?) -> Builder {
    addAttribute(key: .font, object: font)
  }
  
  @discardableResult
  public func setTextColor(_ color: UIColor?) -> Builder {
    addAttribute(key: .foregroundColor, object: color)
  }
  
  @discardableResult
  public func setUnderlineStyle(_ style: NSUnderlineStyle) -> Builder {
    addAttribute(key: .underlineStyle, object: style.rawValue)
  }
  
  @discardableResult
  public func setParagraphStyle(lineSpacing: CGFloat,
                                heightMultiple: CGFloat = 1,
                                lineHeight: CGFloat,
                                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                                textAlignment: NSTextAlignment = .left) -> Builder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle)
  }
  
  @discardableResult
  public func setFont(_ font: UIFont?, range: NSRange) -> Builder {
    addAttribute(key: .font, object: font, range: range)
  }
  
  @discardableResult
  public func setTextColor(_ color: UIColor?, range: NSRange) -> Builder {
    addAttribute(key: .foregroundColor, object: color, range: range)
  }
  
  @discardableResult
  public func setUnderlineStyle(_ style: NSUnderlineStyle, range: NSRange) -> Builder {
    addAttribute(key: .underlineStyle, object: style.rawValue, range: range)
  }
  
  @discardableResult
  public func setParagraphStyle(lineSpacing: CGFloat,
                                heightMultiple: CGFloat = 1,
                                lineHeight: CGFloat,
                                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                                textAlignment: NSTextAlignment = .left,
                                range: NSRange) -> Builder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle, range: range)
  }
  
  @discardableResult
  public func setFont(_ font: UIFont?, substring: String) -> Builder {
    addAttribute(key: .font, object: font, substring: substring)
  }
  
  @discardableResult
  public func setTextColor(_ color: UIColor?, substring: String) -> Builder {
    addAttribute(key: .foregroundColor, object: color, substring: substring)
  }
  
  @discardableResult
  public func setUnderlineStyle(_ style: NSUnderlineStyle, substring: String) -> Builder {
    addAttribute(key: .underlineStyle, object: style.rawValue, substring: substring)
  }
  
  @discardableResult
  public func setParagraphStyle(lineSpacing: CGFloat,
                                heightMultiple: CGFloat = 1,
                                lineHeight: CGFloat,
                                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                                textAlignment: NSTextAlignment = .left,
                                substring: String) -> Builder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle, substring: substring)
  }
}

// MARK: - Private Methods
private extension Builder {
  func validate(range: NSRange) -> Bool {
    guard range.location >= 0, range.length >= 0 else { return false }
    let (end, overflowed) = range.location.addingReportingOverflow(range.length)
    guard !overflowed else { return false }
    return end <= text.utf16.count
  }
}
#endif
