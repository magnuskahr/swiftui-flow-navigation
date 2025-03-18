import Testing
import SwiftUI
@testable import FlowNavigation

struct StringScreen: FlowScreen {
    static let screenId: String = "StringScreen"
    
    func body(control: FlowScreenControl<String>) -> Never {
        fatalError()
    }
}

struct IntScreen: FlowScreen {
    static var screenId: String { "IntScreen" }
    
    func body(control: FlowScreenControl<Int>) -> Never {
        fatalError()
    }
}

@MainActor
struct FlowProxyTests {
    
    @Test
    func retrievesStoredDataSuccessfully() throws {
        let string = "123"
        
        let flowProxy = FlowProxy(
            data: [
                FlowScreenId(for: StringScreen.self): string
            ]
        )

        let retrievedString = try flowProxy.data(for: StringScreen.self)

        #expect(retrievedString == string)
    }
    
    @Test
    func throwsDataUnavailable_whenNoDataStored() {
        let flowProxy = FlowProxy(data: [:]) // No data

        #expect(throws: FlowProxy.DataUnavailable.self) {
            try flowProxy.data(for: StringScreen.self)
        }
    }
    
    @Test
    func throwsDataTypeMismatch_whenStoredDataHasWrongType() {
        let flowProxy = FlowProxy(data: [FlowScreenId(for: IntScreen.self): "not an int"])

        #expect(throws: FlowProxy.DataTypeMismatch.self) {
            try flowProxy.data(for: IntScreen.self)
        }
    }
    
    @Test
    func retrievesDataWithAlias() throws {
        let string = "123"
        let flowProxy = FlowProxy(
            data: [
                FlowScreenId(for: StringScreen.self, alias: "Profile"): string
            ]
        )

        let retrievedString = try flowProxy.data(for: StringScreen.self, alias: "Profile")

        #expect(retrievedString == string)
    }
    
    @Test
    func throwsDataUnavailable_whenAliasIsIncorrect() {
        let string = "123"
        let flowProxy = FlowProxy(
            data: [
                FlowScreenId(for: StringScreen.self, alias: "Profile"): string
            ]
        )

        #expect(throws: FlowProxy.DataUnavailable.self) {
            try flowProxy.data(for: StringScreen.self, alias: "WrongAlias")
        }
    }
}
