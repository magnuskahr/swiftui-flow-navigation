import Testing
@testable import FlowNavigation

@MainActor
struct FlowReaderTests {

    struct ScreenA: FlowScreen {
        static let screenId: String = "A"
        func body(control: FlowScreenControl<Void>) -> Never {
            fatalError()
        }
    }
    
    struct ScreenB: FlowScreen {
        static let screenId: String = "B"
        func body(control: FlowScreenControl<Void>) -> Never {
            fatalError()
        }
    }
    
    enum Screen {
        case a, b
    }
    
    struct ScreenC: FlowScreen {
        static let screenId: String = "C"
        func body(control: FlowScreenControl<Screen>) -> Never {
            fatalError()
        }
    }
    
    @Test func testOutputsInputScreen() async throws {
        let reader = FlowReader { _ in
            ScreenA()
        }
        let emptyProxy = FlowProxy(data: [:])
        let output = try await reader.screen(proxy: emptyProxy)
        
        #expect(output.id == FlowScreenId(for: ScreenA.self))
    }
    
    @Test func testOutputsInputScreenWithAlias() async throws {
        let reader = FlowReader { _ in
            ScreenA().alias("a")
        }
        let emptyProxy = FlowProxy(data: [:])
        let output = try await reader.screen(proxy: emptyProxy)
        
        #expect(output.id == FlowScreenId(for: ScreenA.self, alias: "a"))
    }
    
    @Test func testRunsAsyncFunction() async throws {
        var didRun = false
        
        let reader = FlowReader { _ in
            let task = Task {
                didRun = true
            }
            let _ = await task.value
            ScreenA()
        }
        
        let emptyProxy = FlowProxy(data: [:])
        let output = try await reader.screen(proxy: emptyProxy)
        
        #expect(output.id == FlowScreenId(for: ScreenA.self))
        #expect(didRun)
    }
    
    @Test func testFlowReaderOutputScreenByProxy() async throws {
        
        let reader = FlowReader { proxy in
            switch try proxy.data(for: ScreenC.self) {
            case .a: ScreenA()
            case .b: ScreenB()
            }
        }
        
        let proxyA = FlowProxy(data: [FlowScreenId(for: ScreenC.self): Screen.a])
        let outputA = try await reader.screen(proxy: proxyA)
        #expect(outputA.id == FlowScreenId(for: ScreenA.self))
        
        let proxyB = FlowProxy(data: [FlowScreenId(for: ScreenC.self): Screen.b])
        let outputB = try await reader.screen(proxy: proxyB)
        #expect(outputB.id == FlowScreenId(for: ScreenB.self))
    }
}
