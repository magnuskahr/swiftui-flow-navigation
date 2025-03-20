import SwiftUI

public struct DefaultUnavailableFlowView: View {
    
    public init() {}
    
    public var body: some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            ContentUnavailableView(
                "No screens available",
                systemImage: "questionmark.app"
            )
        } else {
            Text("No screens available")
        }
    }
}
