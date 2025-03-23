import SwiftUI

public struct DefaultUnavailableFlowView: View {
    
    public init() {}
    
    public var body: some View {
        #if swift(>=5.9)
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            ContentUnavailableView(
                "No screens available",
                systemImage: "questionmark.app"
            )
        } else {
            Text("No screens available")
        }
        #else
        Text("No screens available")
        #endif
    }
}
