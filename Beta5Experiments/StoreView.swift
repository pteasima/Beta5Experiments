import SwiftUI

@dynamicMemberLookup protocol StoreView: View {
    associatedtype State
    associatedtype Action
    var store: Store<State, Action> { get }
}

extension StoreView {
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> Subject {
        store[dynamicMember: keyPath]
    }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> (@escaping (Subject) -> Action) -> Binding<Subject> {
        store[dynamicMember: keyPath]
    }
    
    subscript<ActionParam>(dynamicMember keyPath: WritableKeyPath<Action, ActionParam?>) -> (ActionParam) -> Void
        where Action: EmptyInitializable {
            self.store[dynamicMember: keyPath]
    }
}
