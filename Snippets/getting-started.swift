import FlowNavigation
import SwiftUI

// snippet.NameFlowScreen
struct NameFlowScreen: FlowScreen {
    static let screenId: String = "Name"
    
    @State private var name = ""
    
    func body(control: FlowScreenControl<String>) -> some View {
        Form {
            TextField("Name", text: $name)
            Button("Next") {
                Task {
                    await control.next(name)
                }
            }
        }
    }
}
// snippet.Flow1
Flow {
    NameFlowScreen()
}
// snippet.TextInputFlowScreen
struct TextInputFlowScreen: FlowScreen {
    static let screenId: String = "TextInput"

    let title: String

    @State private var input = ""

    func body(control: FlowScreenControl<String>) -> some View {
        Form {
            TextField(title, text: $input)
            Button("Next") {
                Task {
                    await control.next(input)
                }
            }
        }
    }
}
// snippet.Flow2
Flow {
    TextInputFlowScreen(title: "Name")
        .alias("name")

    TextInputFlowScreen(title: "Email")
        .alias("email")
}
// snippet.Flow3
Flow {
    TextInputFlowScreen(title: "Name")
        .alias("name")

    TextInputFlowScreen(title: "Email")
        .alias("email")

    SecureInputFlowScreen(title: "Password")

    FlowReader { proxy in
        SubmissionFlowScreen(
            name: try proxy.data(for: TextInputFlowScreen.self, alias: "name"),
            email: try proxy.data(for: TextInputFlowScreen.self, alias: "email"),
            password: try proxy.data(for: SecureInputFlowScreen.self)
        )
    }
}
// snippet.Flow4
Flow {
    SelectUserIdFlowScreen()

    FlowReader { proxy in
        let userId = try proxy.data(for: SelectUserIdFlowScreen.self)
        let user = try await service.loadUser(id: userId)
        return ConfirmUserScreen(user: user)
    }
}
