import Testing
@testable import FlowNavigation

@Suite("Navigation Push")
@MainActor
struct NavigationPushTests {
    
    private struct _Screen: FlowScreen {
        static let screenId: String = "Screen 1"
        func body(control: FlowScreenControl<Void>) -> Never {
            fatalError()
        }
    }
    
    private struct NilFlowScreenProvider: FlowScreenProvider {
        func screen(proxy: FlowProxy) async throws -> FlowScreenContainer? {
            nil
        }
    }
    
    private func provider(alias: String) -> PassthroughFlowScreenProvider {
        PassthroughFlowScreenProvider(
            container: FlowScreenContainer(screen: _Screen(), alias: alias)
        )
    }
    
    @_disfavoredOverload
    private func provider(alias: String) -> (PassthroughFlowScreenProvider, FlowScreenContainer) {
        (PassthroughFlowScreenProvider(
            container: FlowScreenContainer(screen: _Screen(), alias: alias)
        ), FlowScreenContainer(screen: _Screen(), alias: alias))
    }
    
    @Test
    func testNavigationPushEqualityAndHasing() async throws {
        
        let emptyProxy = FlowProxy(data: [:])
        
        let provider1 = provider(alias: "1")
        let provider2 = provider(alias: "1") // Same ID
        
        let push1 = try #require(await NavigationPush.build(from: [provider1], proxy: emptyProxy))
        let push2 = try #require(await NavigationPush.build(from: [provider2], proxy: emptyProxy))
        
        #expect(push1 == push2, "NavigationPush instances with the same ID should be equal")
        #expect(push1.hashValue == push2.hashValue, "Hash values should be equal for identical NavigationPush instances")
    }
    
    @Test
    func testNavigationPushInequality() async throws {
        let emptyProxy = FlowProxy(data: [:])
        
        let provider1 = provider(alias: "1")
        let provider2 = provider(alias: "2")
        
        let push1 = try #require(await NavigationPush.build(from: [provider1], proxy: emptyProxy))
        let push2 = try #require(await NavigationPush.build(from: [provider2], proxy: emptyProxy))
        
        #expect(push1 != push2, "NavigationPush instances with different IDs should not be equal")
    }

    @Test
    func testNextNavigationPush() async throws {
        let emptyProxy = FlowProxy(data: [:])
        
        let provider1 = provider(alias: "1")
        let (provider2, container2) = provider(alias: "2")
        let (provider3, container3) = provider(alias: "3")
        
        let push = try #require(await NavigationPush.build(from: [provider1, provider2, provider3], proxy: emptyProxy))
    
        let nextPush = try #require(await push.next(proxy: emptyProxy), "A next push should exist")
        #expect(nextPush.container.id == container2.id, "The second screen should match the provider2")
        
        let nextNextPush = try #require(await nextPush.next(proxy: emptyProxy), "A next push should exist")
        #expect(nextNextPush.container.id == container3.id, "The second screen should match the provider2")
    }

    @Test
    func testNextNavigationPushNil() async throws {
        let emptyProxy = FlowProxy(data: [:])
        
        let provider = provider(alias: "1")
        
        let push = try #require(await NavigationPush.build(from: [provider], proxy: emptyProxy))
        
        try #expect(await push.next(proxy: emptyProxy) == nil, "A next push should not exist")
    }
    
    @Test
    func testSkipsNilFlowScreenContainer() async throws {
        let emptyProxy = FlowProxy(data: [:])
        
        let provider1: any FlowScreenProvider = provider(alias: "1")
        let provider2: any FlowScreenProvider = NilFlowScreenProvider()
        let (provider3, container3): (any FlowScreenProvider, FlowScreenContainer) = provider(alias: "3")
        
        let push = try #require(await NavigationPush.build(from: [provider1, provider2, provider3], proxy: emptyProxy))
    
        // provider2 returns `nil`, so we would expect no screen and the second push being container3
        let nextPush = try #require(await push.next(proxy: emptyProxy), "A next push should exist")
        #expect(nextPush.container.id == container3.id, "The second screen should match the provider3")
    }
    
    @Test
    func testNilContainerAsLastProviderFinishesAsNormalWithNil() async throws {
        let emptyProxy = FlowProxy(data: [:])
        
        let provider1: any FlowScreenProvider = provider(alias: "1")
        let provider2: any FlowScreenProvider = NilFlowScreenProvider()
        
        let push = try #require(await NavigationPush.build(from: [provider1, provider2], proxy: emptyProxy))
    
        // provider2 returns `nil`, so we would expect no screen and the second push being container3
        let nextPush = try await push.next(proxy: emptyProxy)
        
        try #require(nextPush == nil, "The second and last provider returns a nil container")
    }
}
