import SwiftUI

/// A proxy that provides access to the output data of previously visited screens in a navigation flow.
///
/// `FlowProxy` is used by **Flow Navigation** to pass data between screens. It allows screens
/// to retrieve output data from earlier steps in the flow in a type-safe manner.
///
/// ## Retrieving Data
/// To access the output of a previous screen, use `data(for:alias:)`:
/// ```swift
/// let user = try proxy.data(for: SelectUserScreen.self)
/// ```
///
/// - Note: If multiple screens use the same `screenId` but have different output types,
///   this may lead to data conflicts. Ensure that screen identifiers are unique to prevent
///   unexpected type mismatches.
public struct FlowProxy: Sendable {
    let data: [FlowScreenId: any Sendable]
    
    struct DataUnavailable: Error {
        let screenId: FlowScreenId
        
        var errorDescription: String? {
            "No output data available for screen ID: \(screenId)."
        }
        
        var failureReason: String? {
            "The requested screen has not produced any output data."
        }
        
        var recoverySuggestion: String? {
            "Ensure that the screen was visited before accessing its output."
        }
    }
    
    struct DataTypeMismatch: LocalizedError {
        let screenId: FlowScreenId
        
        var errorDescription: String? {
            "Unable to cast data for screen ID: \(screenId)."
        }
        
        var failureReason: String? {
            // TODO: Can we create a macro to fix this?
            "Multiple screens probably used the same ID but had different output types, causing data to be overwritten."
        }
        
        var recoverySuggestion: String? {
            "Use unique screen IDs or ensure consistent output types for screens with the same ID."
        }
    }
    
    /// Retrieves the output data of a specific screen from the flow, ensuring type safety.
    ///
    /// This method looks up the output data for a given screen type and alias.
    /// If the requested screen has output data stored, it attempts to cast it to `S.Output`.
    ///
    /// - Note: The alias acts as a unique qualifier for the screen type.
    ///   If two different screen types share the same alias, their data will remain separate
    ///   and **will not conflict** in the flow.
    ///
    /// - Parameter screen: The screen type whose output data should be retrieved.
    /// - Parameter alias: An optional alias used to differentiate screens with the same type.
    /// - Throws:
    ///   - `FlowProxy.DataUnavailable` if no output data exists for the given screen.
    ///   - `FlowProxy.DataTypeMismatch` if the stored data cannot be cast to `S.Output`.
    /// - Returns: The output data for the requested screen.
    ///
    /// ## Example Usage:
    /// ```swift
    /// let user = try proxy.data(for: SelectUserScreen.self)
    /// ```
    @MainActor
    public func data<S>(for screen: S.Type, alias: String? = nil) throws -> S.Output where S: FlowScreen {
        
        let key = FlowScreenId(for: S.self, alias: alias)
        
        guard data.keys.contains(key) else {
            throw DataUnavailable(screenId: key)
        }
        
        guard let output = data[key] as? S.Output else {
            throw DataTypeMismatch(screenId: key)
        }
        
        return output
    }
}
