#  Hiding the Back Button

Hiding the Back Button on a Per-Screen Basis

If you need to hide the back button on a `FlowScreen`, such as a completion screen, you can use SwiftUI’s native [`navigationBarBackButtonHidden(_:)`](https://developer.apple.com/documentation/swiftui/view/navigationbarbackbuttonhidden(_:)) modifier.
Since Flow Navigation is built on `NavigationStack`, this works seamlessly.

@Snippet(path: "swiftui-flow-navigation/Snippets/hiding-the-back-button")
