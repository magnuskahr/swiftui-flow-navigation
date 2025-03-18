import SwiftUI

/// A protocol defining a navigable screen within a `Flow`.
///
/// `FlowScreen` represents a screen that integrates with **Flow Navigation**.
///
/// Screens have a static id (`screenId`) that is used by the `Flow` to store the output.
/// The output type of a screen is also statically known, which is required to allow ``FlowReader``
/// to read the output of an earlier screen.
///
/// - Note: Multiple screens of the same type (and thus the same `screenId`) can exist within a flow.
///   However, if the output is needed, you should define an alias in the flow. See ``FlowScreen/alias(_:)``.
///
/// ## Usage
/// A screen conforms to `FlowScreen` by defining a `body` that receives a `FlowScreenControl`,
/// which allows the screen to signal completion and pass an output.
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
/// If a screen does not return any output, use `Void` as the `Output` type:
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
@MainActor
public protocol FlowScreen: DynamicProperty {
    
    /// The type of output the screen produces upon completion.
    associatedtype Output: Sendable
    
    /// The view type returned by the screen.
    associatedtype Body: View
    
    /// A unique identifier for the screen.
    ///
    /// This identifier is used to track screens within a flow.
    /// It should be globally unique across all `FlowScreen` implementations.
    nonisolated static var screenId: String { get }
    
    /// The content of the screen.
    ///
    /// - Parameter control: A `FlowScreenControl` used to signal when the screen is ready to advance.
    /// - Returns: A SwiftUI `View` representing the screen.
    @ViewBuilder
    func body(control: FlowScreenControl<Output>) -> Body
}

extension FlowScreen {
    /// Renders the screen into a `FlowScreenView`, allowing it to be used in navigation flows.
    ///
    /// - Parameter control: A closure that handles the flow transition when the screen completes.
    /// - Returns: A `FlowScreenView` containing the rendered screen.
    @MainActor
    func render(control: @escaping FlowScreenControlHandler) -> FlowScreenView {
        let control = FlowScreenControl<Output>(handler: control)
        return FlowScreenView(screen: self, control: control)
    }
}

public extension FlowScreen {
    /// Assigns an alias to the screen and returns it as a `FlowScreenContainer`.
    ///
    /// An alias is useful for differentiating screens of the same type within a flow.
    ///
    /// - Parameter alias: A unique string identifier for this specific screen instance.
    /// - Returns: A `FlowScreenContainer` wrapping the screen with the given alias.
    func alias(_ alias: String) -> FlowScreenContainer {
        FlowScreenContainer(screen: self, alias: alias)
    }
}
