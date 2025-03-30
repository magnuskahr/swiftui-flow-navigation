/// Represents a navigation state.
///
/// `NavigationPush` encapsulates a `FlowScreenContainer` and manages the remaining `FlowScreenProvider`
/// instances in a sequence. It allows asynchronous progression through the navigation flow by fetching
/// the next available screen from the remaining providers.
@MainActor
struct NavigationPush: Hashable {
    
    /// Compares two `NavigationPush` instances based on their `id`.
    ///
    /// Two instances are considered equal if they share the same `FlowScreenId`.
    ///
    /// - Parameters:
    ///   - lhs: The first `NavigationPush` instance.
    ///   - rhs: The second `NavigationPush` instance.
    /// - Returns: `true` if both instances have the same `FlowScreenId`, otherwise `false`.
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Computes a hash value for this `NavigationPush` based on its `id`.
    ///
    /// - Parameter hasher: The hasher to use when combining values.
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private let id: FlowScreenId
    
    /// The screen container associated with this navigation state.
    ///
    /// The container encapsulates the `FlowScreen` along with its metadata.
    let container: FlowScreenContainer
    
    private let remainder: ArraySlice<FlowScreenProvider>
                
    /// Creates a `NavigationPush` instance with a given screen container and a sequence of remaining providers.
    ///
    /// - Parameters:
    ///   - container: The `FlowScreenContainer` representing the current screen.
    ///   - remainder: The remaining `FlowScreenProvider` instances in the sequence.
    private init(
        container: FlowScreenContainer,
        remainder: ArraySlice<FlowScreenProvider>
    ) {
        self.container = container
        self.remainder = remainder
        self.id = container.id
    }
    
    /// Attempts to retrieve the next navigation state in the sequence.
    ///
    /// This method asynchronously requests the next `FlowScreenContainer` from the remaining providers
    /// using the given `FlowProxy`. If there are no more providers, `nil` is returned.
    ///
    /// - Parameter proxy: The `FlowProxy` containing output data from previous screens.
    /// - Returns: The next `NavigationPush` instance, or `nil` if there are no remaining screens.
    /// - Throws: An error if the next screen cannot be generated.
    func next(proxy: FlowProxy) async throws -> Self? {
        try await Self.build(from: remainder, proxy: proxy)
    }
    
    /// Builds the next `NavigationPush` instance from a collection of screen providers.
    ///
    /// This method iterates through the provided `FlowScreenProvider` collection, requesting the next
    /// `FlowScreenContainer` asynchronously. If a valid screen is found, it is returned as a `NavigationPush`
    /// with the remaining providers. If no valid screens are available, `nil` is returned.
    ///
    /// - Parameters:
    ///   - providers: A collection of `FlowScreenProvider` instances to process.
    ///   - proxy: The `FlowProxy` containing output data from previous screens.
    /// - Returns: The next `NavigationPush` instance, or `nil` if there are no more screens.
    /// - Throws: An error if a screen cannot be provided.
    static func build<C>(
        from providers: C,
        proxy: FlowProxy
    ) async throws -> Self?
    where C: RandomAccessCollection, C.SubSequence == ArraySlice<FlowScreenProvider> {
        guard !providers.isEmpty else { return nil }
        
        var remainder = ArraySlice(providers)
        
        repeat {
            let provider = remainder.removeFirst()
            if let container = try await provider.screen(proxy: proxy) {
                return NavigationPush(container: container, remainder: remainder)
            }
        } while !remainder.isEmpty
        
        return nil
    }
}
