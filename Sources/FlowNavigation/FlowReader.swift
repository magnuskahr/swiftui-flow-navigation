import SwiftUI

/// A  screen provider with access to a proxy of the current flow outputs.
///
/// `FlowReader` allows you to create screens based on the output data stored in `FlowProxy`.
///
/// ## Usage
/// `FlowReader` is useful when a screen's content depends on prior user interactions.
/// You can initialize it with a closure that receives a `FlowProxy`, which provides access
/// to the output data of previous screens.
///
/// ```swift
/// FlowReader { proxy in
///     let userId = try proxy.data(for: UserSelectionScreen.self)
///     return UserProfileScreen(userId: userId)
/// }
/// ```
///
/// - Note: The closure is async, so you can using it to load data for the screen.
public struct FlowReader: FlowScreenProvider {
    private let handler: @MainActor (FlowProxy) async throws -> FlowScreenContainer
    
    /// Initializes a `FlowReader` that dynamically constructs a `FlowScreen`.
    ///
    /// Use this initializer when you want to create a `FlowScreen` dynamically based on
    /// output data from the `FlowProxy`. The provided closure receives the `FlowProxy`,
    /// allowing access to previous screen outputs, and returns a `FlowScreen`.
    ///
    /// - Parameter handler: A closure that receives a `FlowProxy` and asynchronously returns a `FlowScreen`.
    /// - Throws: An error if the `FlowScreen` cannot be created.
    public init<C>(handler: @escaping @MainActor (FlowProxy) async throws -> C) where C: FlowScreen {
        self.handler = {
            try await FlowScreenContainer(
                screen: handler($0)
            )
        }
    }
    
    /// Initializes a `FlowReader` with a pre-constructed `FlowScreenContainer`.
    ///
    /// This initializer is useful when you already have a `FlowScreenContainer` and want to return it directly.
    /// The provided closure still has access to the `FlowProxy`, making it possible to modify or configure
    /// the container dynamically based on prior screen outputs.
    ///
    /// - Parameter handler: A closure that receives a `FlowProxy` and asynchronously returns a `FlowScreenContainer`.
    /// - Throws: An error if the `FlowScreenContainer` cannot be created.
    public init(handler: @escaping @MainActor (FlowProxy) async throws -> FlowScreenContainer) {
        self.handler = handler
    }
    
    /// Retrieves a `FlowScreenContainer` dynamically using the stored handler.
    ///
    /// This method calls the handler function with the provided `FlowProxy`, allowing
    /// the creation of a `FlowScreenContainer` based on previous navigation steps.
    ///
    /// - Parameter proxy: The `FlowProxy` containing output data from previous screens.
    /// - Returns: A dynamically created `FlowScreenContainer`.
    /// - Throws: An error if the screen cannot be created.
    public func screen(proxy: FlowProxy) async throws -> FlowScreenContainer {
        try await handler(proxy)
    }
}
