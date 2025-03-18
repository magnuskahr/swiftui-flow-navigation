import SwiftUI

/// A loading view that will ensure a 2 second duration if the loading takes more than 0.25 second.
/// This is to ensure that the loading spinner shows for a small amount of time if needed and gives a better experience.
struct LoadingFlowView<Value>: View where Value: Sendable {
    
    @State private var showProgressView = false
    
    let loading: () async throws -> Value
    let result: (Result<Value, Error>) -> Void
    
    var body: some View {
        ProgressView()
            .opacity(showProgressView ? 1 : 0)
            .task {
                do {
                    let value = try await Task.minimumDuration(.seconds(2), exceeding: .seconds(0.25)) {
                        showProgressView = true
                    } action: {
                        try await loading()
                    }
                    
                    result(.success(value))
                } catch {
                    result(.failure(error))
                }
            }
    }
}

private extension Task where Success == Never, Failure == Never {
    
    @MainActor static func minimumDuration<T>(
        _ minDuration: Duration,
        exceeding threshold: Duration,
        onThresholdExceeded: @escaping () -> Void,
        action:  @escaping @MainActor () async throws -> T
    ) async rethrows -> T {
        let start = ContinuousClock().now
        var thresholdExceeded = false
        
        let exceeding = Task<Void, Never> {
            try? await Task.sleep(for: threshold)
            if !Task.isCancelled {
                thresholdExceeded = true
                onThresholdExceeded()
            }
        }

        let result = try await action()  // Run the main task
        exceeding.cancel() // Stop the threshold task if it hasn't triggered

        // If threshold was exceeded, enforce minDuration
        if thresholdExceeded {
            let elapsed = start.duration(to: ContinuousClock().now)
            let remainingTime = minDuration - elapsed
            if remainingTime > .zero {
                try? await Task.sleep(for: remainingTime)
            }
        }

        return result
    }
}




