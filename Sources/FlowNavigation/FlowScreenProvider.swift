/// An internal protocol used by **Flow Navigation** to provide `FlowScreen` instances.
///
/// This protocol is part of the internal mechanics of **Flow Navigation** and is **not meant to be implemented**
/// by users of the library. It is used to dynamically provide `FlowScreen` instances and wrap them
/// in a `FlowScreenContainer`, which also stores metadata about the screen.
///
/// This protocol is marked with `@MainActor`, ensuring that all implementations of `screen(proxy:)`
/// execute on the main thread.
@MainActor
public protocol FlowScreenProvider {
    
    /// Provides a `FlowScreen`  wrapped in a `FlowScreenContainer`.
    ///
    /// - Parameter proxy: A `FlowProxy` that provides access to output data from earlier screens in the flow.
    /// - Returns: A `FlowScreenContainer` that encapsulates the generated `FlowScreen` and its metadata.
    /// - Throws: An error if the screen cannot be createds.
    func screen(proxy: FlowProxy) async throws -> FlowScreenContainer
}
