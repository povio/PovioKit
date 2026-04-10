//
//  TextField.swift
//  PovioKit
//
//  Created by Arlind Dushi on 01/20/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit
import PovioKitCore
import PovioKitUtilities

public protocol RuleValidatable {
  var error: String { get }
  func validate(_ input: String?) -> Bool
}

public class TextField: UIView {
  private let stackView = UIStackView()
  private let titleLabel = PaddingLabel()
  private let valueContainerView = UIView()
  private let valueTextField = UITextField()
  private let errorLabel = UILabel()
  private var rule: RuleValidatable?
  private var textFieldHeightAnchor: NSLayoutConstraint?

  weak public var delegate: UITextFieldDelegate? {
    didSet { valueTextField.delegate = delegate }
  }
  
  public init(with rule: RuleValidatable? = .none) {
    super.init(frame: .zero)
    self.rule = rule
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @discardableResult
  override public func becomeFirstResponder() -> Bool {
    valueTextField.becomeFirstResponder()
  }
  
  @discardableResult
  override public func resignFirstResponder() -> Bool {
    valueTextField.resignFirstResponder()
  }
  
  override public var isFirstResponder: Bool {
    valueTextField.isFirstResponder
  }
  
  public var inputFieldHeight: CGFloat = 44 {
    didSet { textFieldHeightAnchor?.constant = inputFieldHeight }
  }
  
  private var error: String? {
    didSet { errorStateChanged() }
  }
  
  public var isValid: Bool {
    guard let rule = rule else { return true }
    error = rule.validate(text) ? .none : rule.error
    return error == .none
  }
  
  public var title: String = "" {
    didSet {
      titleLabel.text = title
      titleLabel.isHidden = title.isEmpty
    }
  }
  
  public var titleColor: UIColor = .black {
    didSet { titleLabel.textColor = titleColor }
  }
  
  public var titleFont: UIFont = UIFont.systemFont(ofSize: 14) {
    didSet { titleLabel.font = titleFont }
  }
  
  public var text: String? {
    get {
      return valueTextField.text
    }
    set {
      valueTextField.text = newValue
    }
  }
  
  public var enabled: Bool = true {
    didSet { isEnabledStateChanged() }
  }
  
  public var attributedValue: NSAttributedString? {
    didSet { valueTextField.attributedText = attributedValue }
  }
  
  public var accessoryView: UIView? {
    didSet { valueTextField.inputAccessoryView = accessoryView }
  }
  
  public var textFieldInputView: UIView? {
    didSet { valueTextField.inputView = textFieldInputView }
  }
  
  public var keyboardType: UIKeyboardType = .default {
    didSet { valueTextField.keyboardType = keyboardType }
  }
  
  public var returnKeyType: UIReturnKeyType = .default {
    didSet { valueTextField.returnKeyType = returnKeyType }
  }
  
  public var autocapitalizationType: UITextAutocapitalizationType = .sentences {
    didSet { valueTextField.autocapitalizationType = autocapitalizationType }
  }
  
  public var placeholder: String = "" {
    didSet { placeholderStateChanged() }
  }
  
  public var placeholderTextColor: UIColor = .init(red: 129, green: 131, blue: 136) {
    didSet { placeholderStateChanged() }
  }
  
  public var textAlignment: NSTextAlignment = .left {
    didSet { valueTextField.textAlignment = textAlignment }
  }
  
  public var textFont: UIFont = UIFont.systemFont(ofSize: 16) {
    didSet { valueTextField.font = textFont }
  }
  
  public var textColor: UIColor = .black {
    didSet { valueTextField.textColor = textColor }
  }
  
  public var errorTextColor: UIColor = .red {
    didSet { errorLabel.textColor = errorTextColor }
  }
  
  public var textFieldBackgroundColor: UIColor = .init(red: 225, green: 230, blue: 243) {
    didSet { valueContainerView.backgroundColor = textFieldBackgroundColor }
  }
  
  public var textFieldCornerRadius: CGFloat = 10 {
    didSet { valueContainerView.layer.cornerRadius = textFieldCornerRadius }
  }
  
  public var textFieldBorderWidth: CGFloat = 0 {
    didSet { valueContainerView.layer.borderWidth = textFieldBorderWidth }
  }
  
  public var textFieldBorderColor: UIColor? {
    didSet { valueContainerView.layer.borderColor = textFieldBorderColor?.cgColor }
  }
  
  public var leftView: UIView? {
    didSet {
      valueTextField.leftView = leftView
      valueTextField.leftViewMode = .always
    }
  }
  
  public var rightView: UIView? {
    didSet {
      valueTextField.rightView = rightView
      valueTextField.rightViewMode = .always
    }
  }
  
  public var textContentType: UITextContentType? {
    didSet {
      valueTextField.textContentType = textContentType
    }
  }
}

// MARK: - Public Methods
public extension TextField {
  func setRule(_ rule: RuleValidatable) {
    self.rule = rule
  }
}

// MARK: - Private Methods
private extension TextField {
  func setupViews() {
    setupStackView()
  }
  
  func setupStackView() {
    func setupTitleLabel() {
      stackView.addArrangedSubview(titleLabel)
      titleLabel.contentInset = .init(horizontal: 4)
      titleLabel.font = titleFont
      titleLabel.textColor = titleColor
      titleLabel.isHidden = true
    }
    
    func setupValueContainerView() {
      stackView.addArrangedSubview(valueContainerView)
      valueContainerView.backgroundColor = textFieldBackgroundColor
      valueContainerView.layer.cornerRadius = textFieldCornerRadius
      valueContainerView.layer.masksToBounds = true
      
      valueContainerView.translatesAutoresizingMaskIntoConstraints = false
      textFieldHeightAnchor = valueContainerView.heightAnchor.constraint(equalToConstant: inputFieldHeight)
      textFieldHeightAnchor?.isActive = true
    }
    
    func setupValueTextField() {
      valueContainerView.addSubview(valueTextField)
      valueTextField.font = textFont
      valueTextField.textColor = textColor
      
      valueTextField.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        valueTextField.leadingAnchor.constraint(equalTo: valueContainerView.leadingAnchor, constant: 15),
        valueTextField.trailingAnchor.constraint(equalTo: valueContainerView.trailingAnchor, constant: -15),
        valueTextField.topAnchor.constraint(equalTo: valueContainerView.topAnchor),
        valueTextField.bottomAnchor.constraint(equalTo: valueContainerView.bottomAnchor)
      ])
    }
    
    func setupErrorLabel() {
      stackView.addArrangedSubview(errorLabel)
      errorLabel.font = textFont
      errorLabel.textColor = errorTextColor
      errorLabel.isHidden = true
    }
    
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 8
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    
    setupTitleLabel()
    setupValueContainerView()
    setupValueTextField()
    setupErrorLabel()
    stackView.setCustomSpacing(6, after: valueContainerView)
  }
}

// MARK: - Actions
private extension TextField {
  func errorStateChanged() {
    UIView.animate(withDuration: 0.3) {
      self.errorLabel.isHidden = self.error.isNilOrEmpty
      self.errorLabel.text = self.error
    }
  }
  
  func isEnabledStateChanged() {
    valueTextField.isEnabled = enabled
    valueContainerView.backgroundColor = enabled
      ? textFieldBackgroundColor
      : textFieldBackgroundColor.withAlphaComponent(0.3)
  }
  
  func placeholderStateChanged() {
    valueTextField.attributedPlaceholder = Builder(text: placeholder)
      .setFont(valueTextField.font)
      .setTextColor(placeholderTextColor)
      .create()
  }
}

#endif
