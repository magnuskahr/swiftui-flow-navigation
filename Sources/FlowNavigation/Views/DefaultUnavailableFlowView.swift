import SwiftUI

public struct DefaultUnavailableFlowView: View {
    
    public init() {}
    
    public var body: some View {
        if #available(macOS 14.0, *), #available(iOS 17.0, *) {
            ContentUnavailableView(
                "No screens available",
                systemImage: "questionmark.app"
            )
        } else {
            Text("No screens available")
        }
    }
}
