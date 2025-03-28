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
// snippet.hide
struct _Flow1: View {
    var body: some View {
        // snippet.show
        Flow {
            NameFlowScreen()
        }
        // snippet.end
    }
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
// snippet.hide
struct _Flow2: View {
    var body: some View {
        // snippet.show
        Flow {
            TextInputFlowScreen(title: "Name")
                .alias("name")
            
            TextInputFlowScreen(title: "Email")
                .alias("email")
        }
        // snippet.end
    }
}
// snippet.Flow3
// snippet.hide
struct _Flow3: View {
    var body: some View {
        // snippet.show
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
        // snippet.end
    }
}

// snippet.Flow4
// snippet.hide
struct _Flow4: View {
    let service = Service()
    var body: some View {
        // snippet.show
        Flow {
            SelectUserIdFlowScreen()
            
            FlowReader { proxy in
                let userId = try proxy.data(for: SelectUserIdFlowScreen.self)
                let user = try await service.loadUser(id: userId)
                ConfirmUserScreen(user: user)
            }
        }
        // snippet.end
    }
}
// snippet.end
struct SubmissionFlowScreen: FlowScreen {
    let name: String
    let email: String
    let password: String
    static let screenId = "Submission"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}
struct SecureInputFlowScreen: FlowScreen {
    let title: String
    static let screenId = "SecureInput"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}
struct SelectUserIdFlowScreen: FlowScreen {
    static let screenId = "SelectUser"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}
struct ConfirmUserScreen: FlowScreen {
    let user: String
    static let screenId = "Confirm"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}
struct Service {
    func loadUser(id: String) async throws -> String { id }
}

