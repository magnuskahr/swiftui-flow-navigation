public struct FlowScreenContainer {
    
    let screen: any FlowScreen
    let id: FlowScreenId
    
    init<S>(screen: S, alias: String? = nil) where S: FlowScreen {
        self.screen = screen
        self.id = FlowScreenId(for: S.self, alias: alias)
    }
}
