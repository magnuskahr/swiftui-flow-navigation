# Flow Navigation

Flow Navigation is a **declarative navigation system** for SwiftUI that enables **structured, type-safe flows**.  
It provides a **seamless way to transition between screens**, **pass data** between them, and **handle navigation logic dynamically**.

Using Flow Navigation, you can define your linear flow simply as:

```swift
Flow {
    IntroductionScreen()
    UserSelectionScreen(users: users)
    FlowReader { proxy in
        let selection = try proxy.data(for: UserSelectionScreen.self)
        return ConfirmationScreen(user: selection)
    }
}
```

---

## 📖 Getting Started

### **1. Define Your Screens**

Each screen **conforms to `FlowScreen`**.

They have a static screenId, and defines the body and output of the screen.
The body method has the control parameter, that is used to advance the flow to the next screen.

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

### 2. Create a Flow

A Flow defines the sequence of screens and automatically progresses when a screen completes.

```swift
Flow {
    IntroductionScreen()
    UserSelectionScreen(users: users)
    FlowReader { proxy in
        let selection = try proxy.data(for: UserSelectionScreen.self)
        return ConfirmationScreen(user: selection)
    }
}
```

The flow will then be:

1. An introduction is first shown.
2. Then a screen to select a user; the selected user is passed on to the flow system.
3. A `FlowReader` is used to read the selected user id and passes it along to the confirmation screen.

## 🚀 Installation

Swift Package Manager (SPM)
1.    Open Xcode and go to File > Swift Packages > Add Package Dependency
2.    Enter the repository URL: https://github.com/your-repo/FlowNavigation.git
3.    Select the latest version and add it to your project.
