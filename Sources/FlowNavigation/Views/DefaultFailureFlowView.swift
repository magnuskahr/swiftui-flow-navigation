import SwiftUI

public struct DefaultFailureFlowView: View {

    private let error: Error

    public init(error: Error) {
        self.error = error
    }

    public var body: some View {
        if #available(macOS 14.0, *), #available(iOS 17.0, *) {
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
