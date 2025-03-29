import FlowNavigation
import SwiftUI

// snippet.FlowReaderExample
// snippet.hide
struct FlowReaderExample: View {
    let service = Service()
    var body: some View {
        // snippet.show
        Flow {
            SelectUserIdFlowScreen()
            FlowReader { proxy in
                let userID = try proxy.data(for: SelectUserIdFlowScreen.self)
                try await service.deleteUser(id: userID)
                // Success! lets show a screen:
                SuccessScreen()
            }
        }
        // snippet.end
    }
}
// snippet.CompletionExample
// snippet.hide
struct CompletionExample Service()
    var body: some View {
        // snippet.show
        Flow {
            SelectUserIdFlowScreen()
        } completion: { proxy in
            let userID = try proxy.data(for: SelectUserIdFlowScreen.self)
            try await service.deleteUser(id: userID)
            return .dismiss
        }
        // snippet.end
    }
}
// snippet.end
struct Service {
    func deleteUser(id: String) async throws { }
}
struct SelectUserIdFlowScreen: FlowScreen {
    static let screenId = "SelectUser"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}

struct SuccessScreen: FlowScreen {
    static let screenId = "Success"
    func body(control: FlowScreenControl<String>) -> some View {
        EmptyView()
    }
}
