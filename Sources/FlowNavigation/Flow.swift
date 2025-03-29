import SwiftUI

/// A view of the **Flow Navigation** system that manages and displays a sequence of screens in a SwiftUI `NavigationStack`.
///
/// `Flow` is responsible for orchestrating navigation through a series of ``FlowScreen``
/// instances, handling failures, and managing navigation paths. It supports dynamically
/// loading screens, handling screen outputs via ``FlowProxy``, and providing custom views for
/// unavailable or failure states.
///
/// ## Overview
/// `Flow` acts as the entry point for defining a sequence of screens that guide the user through a process.
/// The screen sequence are declared using the ``Flow/Builder`` result builder, ensuring a declarative API for constructing flows.
///
/// ```swift
/// Flow {
///     UserSelectionScreen()
///     if shouldShowConfirmation {
///         ConfirmationScreen()
///     }
/// }
/// ```
///
/// ## Reading data from a screen
/// A screen can depend on the output of an earlier screen in the flow using a ``FlowReader``.
///
/// ```swift
/// Flow {
///     UserSelectionScreen()
///     FlowReader { proxy in
///         let userId = try proxy.data(for: UserSelectionScreen.self)
///         return UserProfileScreen(userId: userId)
///     }
/// }
/// ```
///
/// If the same screen is used multiple times, it is important to use aliases:
///
/// ```swift
/// Flow {
///     AccountSelectionScreen(accounts: from).alias("From")
///     AccountSelectionScreen(accounts: to).alias("To")
///     FlowReader { proxy in
///         let from = try proxy.data(for: AccountSelectionScreen.self, alias: "From")
///         let to = try proxy.data(for: AccountSelectionScreen.self, alias: "To")
///         return SendMoneyScreen(from: from, to: to)
///     }
/// }
/// ```
///
/// ## Completion
/// A flow completes when its out of screens to push.
/// The default behavior is to just call the dismiss action of the environment.
///
/// To set a custom completion action, specify it in the trailing closure:
///
/// ```swift
/// Flow {
///     // Screens omitted
/// } completion: { proxy in
///     service.deleteUser(
///         user: proxy.data(for: SelectUserForDeletionScreen.self)
///     )
///     return .dismiss
/// }
/// ```
///
/// ## Handling Failures and Unavailable States
/// If no screens are available at runtime, the `unavailable` view is shown.
/// If a screen fails, the `failure` view is displayed.
/// When no custom views are defined, `Flow` will use ``DefaultUnavailableFlowView`` and ``DefaultFailureFlowView``.
///
/// ```swift
/// Flow {
///     UserSelectionScreen()
///     ConfirmationScreen()
/// } unavailable: {
///     Text("No screens available.")
/// } failure: { error in
///     Text("Something went wrong: \(error.localizedDescription)")
/// }
/// ```
///
/// - Important: Screens can provide their own internal navigation destinations. If a screen uses a [destination-based navigation link](https://developer.apple.com/documentation/swiftui/navigationlink#Presenting-a-destination-view), the `Flow` may produce visual glitches when advancing screens. This is a SwiftUI issue and can be resolved by using [value-based navigation links](https://developer.apple.com/documentation/swiftui/navigationlink#Presenting-a-value).
public struct Flow<Unavailable, Failure>: View where Unavailable: View, Failure: View {
    
    private enum Root {
        case available(NavigationPush)
        case unavailable
        case failure(Error)
    }
    
    public enum CompletionResult: Sendable {
        /// The handler removed the flow
        case handled
        /// The handler asks the system to use the environment dismiss action
        case dismiss
    }
    
    @Environment(\.dismiss) private var dismiss
    
    private let providers: [FlowScreenProvider]
    private let unavailable: Unavailable
    private let failure: (Error) -> Failure
    private let completion: (FlowProxy) async throws -> CompletionResult
    
    @State private var root: Root?
    @State private var navigationpath = NavigationPath()
    @State private var data: [FlowScreenId: any Sendable] = [:]
    
    /// Initializes a `Flow` with a sequence of screens, using the default unavailable and failure views.
    ///
    /// This initializer creates a navigation flow from the provided ``FlowScreenProvider`` instances.
    /// If no screens are available, a ``DefaultUnavailableFlowView`` is shown.
    /// If an error occurs, a ``DefaultFailureFlowView`` is presented.
    ///
    /// - Parameters:
    ///    - builder: A ``Flow/Builder`` result builder that defines the sequence of screens in the flow.
    ///    - completion: A closure receiving a ``FlowProxy`` to run when the flow completes
    ///
    /// ## Example
    /// ```swift
    /// Flow {
    ///     UserSelectionScreen()
    ///     ConfirmationScreen()
    /// }
    /// ```
    public init(
        @Builder screens builder: () -> [FlowScreenProvider],
        completion: @escaping (FlowProxy) async throws -> CompletionResult = { _ in .dismiss }
    ) where Unavailable == DefaultUnavailableFlowView, Failure == DefaultFailureFlowView {
        self.providers = builder()
        self.completion = completion
        self.unavailable = Unavailable()
        self.failure = {
            Failure(error: $0)
        }
    }
    
    /// Initializes a `Flow` with a sequence of screens and custom unavailable/failure views.
    ///
    /// This initializer allows you to provide a custom view when no screens are available (`unavailable`)
    /// and a custom view for handling errors (`failure`).
    ///
    /// - Parameters:
    ///   - builder: A ``Flow/Builder`` result builder that defines the sequence of screens in the flow.
    ///   - completion: A closure receiving a ``FlowProxy`` to run when the flow completes
    ///   - unavailable: A closure returning a custom view to be displayed when no screens are available.
    ///   - failure: A closure that receives an `Error` and returns a custom view for handling failures.
    ///
    /// ## Example
    /// ```swift
    /// Flow {
    ///     UserSelectionScreen()
    ///     ConfirmationScreen()
    /// } unavailable: {
    ///     Text("No screens available.")
    /// } failure: { error in
    ///     Text("Something went wrong: \(error.localizedDescription)")
    /// }
    /// ```
    public init(
        @Builder screens builder: () -> [FlowScreenProvider],
        completion: @escaping (FlowProxy) async throws -> CompletionResult = { _ in .dismiss },
        unavailable: () -> Unavailable,
        failure: @escaping (Error) -> Failure
    ) {
        self.providers = builder()
        self.completion = completion
        self.unavailable = unavailable()
        self.failure = failure
    }
    
    private var proxy: FlowProxy {
        FlowProxy(data: data)
    }
    
    public var body: some View {
        if let root {
            switch root {
            case let .available(push):
                NavigationStack(path: $navigationpath) {
                    push.container.screen
                        .render(
                            control: control(push: push)
                        )
                        .navigationDestination(
                            for: NavigationPush.self
                        ) { push in
                            let control = self.control(push: push)
                            push.container.screen.render(control: control)
                        }
                        .navigationDestination(
                            for: _ScreenProviderFailure.self
                        ) { failure in
                            self.failure(failure.error)
                        }
                }
            case .unavailable:
                unavailable
            case let .failure(error):
                failure(error)
            }
        } else {
            LoadingFlowView {
                try await NavigationPush.build(from: providers, proxy: proxy)
            } result: { result in
                switch result {
                case let .success(.some(push)):
                    self.root = .available(push)
                case .success(.none):
                    self.root = .unavailable
                case let .failure(error):
                    self.root = .failure(error)
                }
            }
        }
    }
    
    // TODO: Consider extracting this out to a testable type or someting. It could make sense, but it also requires a lot of dependencies to do the calculation–which might be ugly?
    /// Creates the control handler for a push
    @MainActor // Needed for CI reasons
    private func control(
        push: NavigationPush
    ) -> FlowScreenControlHandler {
        { output in
            
            // If an output is available, we need to store it
            if let output {
                data[push.container.id] = output
            }
            
            do {
                // Try to append the next screen
                if let next = try await push.next(proxy: proxy) {
                    navigationpath.append(next)
                }
                // No more screens are available, lets run the completion and see if we should dismiss
                else {
                    let result = try await completion(proxy)
                    if result == .dismiss {
                        dismiss()
                    }
                }
            }
            // Push the failure screen
            catch {
                navigationpath.append(
                    _ScreenProviderFailure(error: error)
                )
            }
        }
    }
    
    private struct _ScreenProviderFailure: Hashable {
        
        private let id = UUID()
        
        let error: Error
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

public extension Flow {
    @MainActor
    @resultBuilder
    struct Builder {
        public static func buildBlock(_ components: [FlowScreenProvider]...) -> [FlowScreenProvider] {
            components.flatMap { $0 }
        }
        
        public static func buildEither(first component: [FlowScreenProvider]) -> [FlowScreenProvider] {
            component
        }
        
        public static func buildEither(second component: [FlowScreenProvider]) -> [FlowScreenProvider] {
            component
        }
        
        public static func buildOptional(_ component: [FlowScreenProvider]?) -> [FlowScreenProvider] {
            component ?? []
        }
        
        public static func buildArray(_ components: [[FlowScreenProvider]]) -> [FlowScreenProvider] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expression: FlowScreenContainer) -> [FlowScreenProvider] {
            [
                PassthroughFlowScreenProvider(
                    container: expression
                )
            ]
        }
        
        public static func buildExpression<S: FlowScreen>(_ expression: S) -> [FlowScreenProvider] {
            [
                PassthroughFlowScreenProvider(
                    content: expression
                )
            ]
        }
        
        public static func buildExpression(_ expression: FlowScreenProvider) -> [FlowScreenProvider] {
            [expression]
        }
    }
}
