struct PassthroughFlowScreenProvider: FlowScreenProvider {
    
    private let container: FlowScreenContainer
    
    init(container: FlowScreenContainer) {
        self.container = container
    }
    
    init<C>(content: C) where C: FlowScreen {
        self.container = FlowScreenContainer(screen: content)
    }
    
    func screen(proxy: FlowProxy) async throws -> FlowScreenContainer? {
        container
    }
}
