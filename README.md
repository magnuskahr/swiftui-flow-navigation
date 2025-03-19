# Flow Navigation

Flow Navigation is a **declarative navigation system** for SwiftUI that enables **linear, structured, type-safe flows**.  
It provides a **seamless way to set up screens**, **pass data** between them, and **handle navigation logic dynamically**.

Using Flow Navigation, you can define your linear flow simply as:

```swift
Flow {

    IntroductionScreen()
    
    UserSelectionScreen(users: users)
    
    FlowReader { proxy in
        // Read data typesafe from the user selection screen
        let selection = try proxy.data(for: UserSelectionScreen.self)
        return ConfirmationScreen(user: selection)
    }
    
}
```

---

> [!IMPORTANT]
> This framework is currently in beta and has not been battle-tested.
> I am actively developing an app to **dogfood** it, but feel free to use it and report any issues.  
> Your feedback is highly valuable in improving **Flow Navigation**! 🚀

---

## 📖 Getting Started

### **1. Define Your Screens**

Each screen **conforms to `FlowScreen`**.

Each screen has a static screenId and defines both its body and Output type.
The body method receives a control parameter, which is used to advance the flow.

```swift
struct IntroductionScreen: FlowScreen {
    static let screenId = "IntroductionScreen"

    func body(control: FlowScreenControl<Void>) -> some View {
        Text("This screen has no output, hence the Void type.")
        Text("It is just an intro screen.")
        Button("Continue") {
            Task {
                await control.next() // Advance to the next screen
            }
        }
    }
}
```

Screens can also advance with an output.

```swift
struct UserSelectionScreen: FlowScreen {
    static let screenId = "UserSelectionScreen"
    
    let users: [User]

    func body(control: FlowScreenControl<UUID>) -> some View {
        List(users) { user in
            Button(user.name) {
                Task {
                    await control.next(user.id) // Pass selected user ID and advance
                }
            }
        }
    }
}
```

> [!NOTE]
> It can be a good idea to have a dedicated TaskButton view to handle the `FlowScreenControl`.
> FlowNavigation does not ship with one.
> <details>
> <summary>... but its easely created</summary>
>
> ```swift
>   import SwiftUI
>   
>   struct TaskButton<Label>: View where Label: View {
>   
>       @State private var runTask = false
>   
>       private let label: Label
>       private let action: @Sendable () async -> Void
>   
>       init(
>           @_inheritActorContext _ action: @escaping @Sendable () async -> Void,
>           @ViewBuilder label: () -> Label
>       ) {
>           self.label = label()
>           self.action = action
>       }
>   
>       init<S: StringProtocol>(
>           _ title: S,
>           @_inheritActorContext _ action: @escaping @Sendable () async -> Void
>       ) where Label == Text {
>           self.label = Text(title)
>           self.action = action
>       }
>   
>       var body: some View {
>           Button {
>               runTask = true
>           } label: {
>               label
>           }
>           .task(id: runTask, priority: .userInitiated) {
>               guard runTask else { return }
>               await action()
>               runTask = false
>           }
>       }
>   }
> ```
> </detail>

### 2. Create a Flow

A Flow defines the sequence of screens and automatically progresses when a screen completes.
Use the flow as any other SwiftUI view.
When a flow is finished, it will call the dismiss environment action, so its suitable for being shown in sheets.

```swift
var body: some View {
    Button("Select user") {
        showSelectUserFlow = true
    }
    .sheet(isPresented: $showSelectUserFlow) {
        Flow {
            IntroductionScreen()
            UserSelectionScreen(users: users)
            FlowReader { proxy in
                let selection = try proxy.data(for: UserSelectionScreen.self)
                return ConfirmationScreen(user: selection)
            }
        }
    }
}
```

The flow progresses linearly as follows:

1. The `IntroductionScreen` is shown first.
2. The `UserSelectionScreen` allows the user to select a user, passing the selected ID to the flow.
3. `FlowReader` reads the selected user’s ID and passes it to the `ConfirmationScreen`.

## 🚀 Installation

To use this package in a SwiftPM project, you need to set it up as a package dependency:

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/magnuskahr/swiftui-flow-navigation", from: "0.0.1")
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "FlowNavigation", package: "swiftui-flow-navigation")
      ]
    )
  ]
)
```
