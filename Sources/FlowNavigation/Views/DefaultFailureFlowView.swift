import SwiftUI

public struct DefaultFailureFlowView: View {

    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    public var body: some View {
        #if swift(>=5.9)
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            ContentUnavailableView(
                "Error",
                systemImage: "exclamationmark.triangle.fill",
                description: Text(error.localizedDescription)
            )
        } else {
            Text(error.localizedDescription)
        }
        #else
        Text(error.localizedDescription)
        #endif
    }
}
