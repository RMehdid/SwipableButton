# SwipableButton

SwipableButton is a SwiftUI view that presents a slide button that can be swiped to unlock or perform an action. This customizable button is designed to provide an engaging and interactive user interface element for your iOS and macOS apps.

## Features

- Swipe to unlock or trigger an action.
- Customizable appearance, including text alignment, indicator size, colors, and more.
- Animation and feedback effects for user engagement.
- Accessibility and isEnabled support.
- SwiftUI-compatible for easy integration into your projects.

## Installation

### Swift Package Manager

You can add SwipableButton to your project using Swift Package Manager. In Xcode, go to `File` -> `Swift Packages` -> `Add Package Dependency` and enter the package URL:

https://github.com/RMehdid/SwipableButton.git


### Manual Installation

You can also manually integrate SwipableButton into your project by copying the source files from this repository.

## Usage

Here's how you can use SwipableButton in your SwiftUI views:

```swift
import SwipableButton

// ...

struct ContentView: View {
    var body: some View {
        SwipableButton("Unlock", action: unlockAction)
    }

    func unlockAction() async {
        // Perform your action here.
    }
}
```

For more customization options and examples, refer to the Documentation section.

## Documentation

For detailed documentation and usage examples, visit the SwipableButton Documentation.

### Contributing

Contributions are welcome! If you have any ideas, bug reports, or feature requests, please open an issue or submit a pull request.

### License

SwipableButton is available under the **MIT license.** See the **LICENSE** file for more information.
