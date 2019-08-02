import SwiftUI

@dynamicMemberLookup protocol StoreView: View {
    associatedtype State
    associatedtype Action
    var store: Store<State, Action> { get set }
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
    subscript<P1,P2>(dynamicMember keyPath: WritableKeyPath<Action, (P1, P2)?>) -> (P1, P2) -> Void
        where Action: EmptyInitializable {
            self.store[dynamicMember: keyPath]
    }
}
