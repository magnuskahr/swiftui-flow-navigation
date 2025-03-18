import SwiftUI

/// A view that renders a `FlowScreen` and ensures it supports using SwiftUI propperty wrappers.
struct FlowScreenView: View {
    let body: AnyView
    
    init<S: FlowScreen>(
        screen: S,
        control: FlowScreenControl<S.Output>
    ) {
        self.body = AnyView(
            Resolver(
                screen: screen,
                control: control
            )
        )
    }
    
    private struct Resolver<S: FlowScreen>: View {
        let screen: S
        let control: FlowScreenControl<S.Output>
        
        var body: some View {
            screen.body(control: control)
        }
    }
}
