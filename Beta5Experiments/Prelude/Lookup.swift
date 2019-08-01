// this only supports mutable models (WritableKeyPaths to model)
// adding KeyPath type as associated type is in theory possible but currently Swift makes conforming to it impossible
// if needed add a separate `ReadonlyLookup` protocol
@dynamicMemberLookup protocol Lookup {
    associatedtype Model
    static var model: WritableKeyPath<Self, Model> { get }
}

extension Lookup {
    subscript<Subject>(dynamicMember keyPath: KeyPath<Model, Subject>) -> Subject {
        self[keyPath: Self.model.appending(path: keyPath)]
    }
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Model, Subject>) -> Subject {
        get { self[dynamicMember: keyPath as KeyPath<Model, Subject>] }
        set {
            self[keyPath: Self.model.appending(path: keyPath)] = newValue

        }
    }
}
