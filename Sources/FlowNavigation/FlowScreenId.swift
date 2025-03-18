struct FlowScreenId: Hashable {
    
    private let screenId: String
    private let alias: String?
    
    init<S>(for screen: S.Type, alias: String? = nil) where S: FlowScreen {
        self.screenId = S.screenId
        self.alias = alias
    }
}

extension FlowScreenId: CustomStringConvertible {
    var description: String {
        if let alias {
            return #"(screenId: "\#(screenId)", alias: "\#(alias)")"#
        } else {
            return #"(screenId: "\#(screenId)")"#
        }
    }
}
