#  TextField

A generic, customizable textfield with optional validation.
Includes `RuleValidatable` protocol to validate input and show an appropriate error message.

## Usage

### Example

1. Create a textfield without validation
`let textField = TextField()`

2. Create a textfield with validation
```swift
struct RequiredRule: RuleValidatable {
  let error: String
  
  init(error: String = "Need input") {
    self.error = error
  }
  
  func validate(_ input: String?) -> Bool {
    input.noneIfEmpty != .none
  }
}
```

Create a rule and attach it to the textfield on initial creation
```swift
lazy var requiredRule = RequiredRule()
let validatableTextField = TextField(with: requiredRule)
```

A rule can also be attached later
```swift
let requiredRule = RequiredRule()
let validatableTextField = TextField()
...

validatableTextField.set(rule)
```

To check if textField is valid
```swift
guard validatableTextField.isValid else { return }
```

Validation will be triggered when `validatableTextField.isValid` is called. If validation doesn't pass, the error message will automatically display under the textfield.

## Source code
You can find source code [here](/Sources/UI/UIKit/Views/TextField/TextField.swift).
