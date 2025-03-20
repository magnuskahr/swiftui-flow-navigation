import SwiftUI

public struct DefaultFailureFlowView: View {

    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    public var body: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle.fill",
                description: Text(error.localizedDescription)
            )
        } else {
            Text(error.localizedDescription)
        }
    }
}
