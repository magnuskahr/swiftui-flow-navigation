typealias FlowScreenControlHandler = @MainActor ((any Sendable)?) async -> ()

/// A control mechanism for advancing a flow by providing an output.
///
/// `FlowScreenControl` allows a screen to signal its completion and pass an output
/// to the navigation system, ensuring that the expected output type is correctly handled.
///
/// ## Usage
/// `FlowScreenControl` is generic over its output type, ensuring type safety through the flow.
/// Use it to pass data from a screen and advance the flow:
///
/// ```swift
/// struct UserSelectionScreen: FlowScreen {
///     static let screenId = "UserSelectionScreen"
///
///     func body(control: FlowScreenControl<UUID>) -> some View {
///         Button("Select User") {
///             Task {
///                 await control.next(UUID())
///             }
///         }
///     }
/// }
/// ```
///
/// If a screen does not return any output, use `Void` as the output type:
///
/// ```swift
/// struct ConfirmationScreen: FlowScreen {
///     static let screenId = "ConfirmationScreen"
///
///     func body(control: FlowScreenControl<Void>) -> some View {
///         Button("Continue") {
///             Task {
///                 await control.next()
///             }
///         }
///     }
/// }
/// ```
public struct FlowScreenControl<Output> where Output: Sendable {

    /// A handler that processes the output and advances the flow.
    let handler: FlowScreenControlHandler
    
    /// Advances the flow by passing the provided output.
    ///
    /// This method should be called when a screen has completed its task and is ready
    /// to provide an output and transition to the next step in the flow.
    ///
    /// - Parameter output: The output value produced by the screen.
    @MainActor
    public func next(_ output: Output) async {
        await handler(output)
    }
}

extension FlowScreenControl where Output == Void {
    
    /// Advances the flow without providing an output.
    ///
    /// This method is useful for screens that do not return any meaningful output.
    @MainActor
    public func next() async {
        await handler(nil)
    }
}
