// snippet.hide
import FlowNavigation
import SwiftUI
// snippet.show
struct CompletionScreen: FlowScreen {
    static let screenId = "Completion"
    
    func body(control: FlowScreenControl<Void>) -> some View {
        VStack {
            Text("Success! You submitted your request!")
            
            Button("Okay") {
                Task {
                    await control.next()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
