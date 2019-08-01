//
//  ContentView.swift
//  Beta5Experiments
//
//  Created by Petr Šíma on 31/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import SwiftUI
import Combine

protocol EmptyInitializable {
    init()
}

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

struct Effect<Action, Environments> {
    
}
struct SubscriptionEffect<Action, Environment>: Equatable {
    
}

final class StateObject<State>: ObservableObject {
    init(state: State) { self.state = state }
    @Published var state: State
}

@dynamicMemberLookup final class Store<State, Action> {
    @ObservedObject private var stateObject: StateObject<State>
    let dispatch: (Action) -> ()
    
    private var strongReferences: [Any] = [] //used to retain Cancellables and Application, no need to track type of either
    
    //this generic version segfaults at callsite, we need to typeErase for now
    //    private init<P: Publisher>(initialState: State, dispatch: @escaping (Action) -> Void, willChange: P) where P.Output == State, P.Failure == Never { }
    
    private init(initialState: State, dispatch: @escaping (Action) -> Void, willChange: AnyPublisher<State, Never>) {
        stateObject = StateObject(state: initialState)
        self.dispatch = dispatch
        strongReferences.append(willChange.assign(to: \.state, on: stateObject))
    }
    
    static func application<Environment>(environment: Environment, initial: (state: State, effects: [Effect<Action, Environment>]), reduce: @escaping (inout State) -> [Effect<Action, Environment>], subscriptions: (State) -> [SubscriptionEffect<Action, Environment>]) -> Store {
        //TODO: use Program internally (rename to Application)
        Store.just(initial.0)
    }
    
    static func just(_ state: State) -> Store {
        self.init(initialState: state, dispatch: {
            print($0)
        }, willChange: Empty(completeImmediately: true).eraseToAnyPublisher())
    }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> Subject {
        stateObject.state[keyPath: keyPath]
    }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> (@escaping (Subject) -> Action) -> Binding<Subject> {
    { transform in
        Binding(get: {
            self[dynamicMember: keyPath]
        }, set: { newValue in
            self.dispatch(transform(newValue))
        })
        }
    }
    subscript<ActionParam>(dynamicMember keyPath: WritableKeyPath<Action, ActionParam?>) -> (ActionParam) -> Void
        where Action: EmptyInitializable {
            {
                var action = Action()
                action[keyPath: keyPath] = $0
                self.dispatch(action)
            }
    }
}

struct AppState {
    var foo: Bool = true
}

enum Action {
    case none
    case onTick(Date)

    var none: Void? {
        get {
            guard case .none = self else { return nil }
            return ()
        }
        set {
            guard let _ = newValue else { return }
            self = .none
        }
    }

    var onTick: Date? {
        get {
            guard case let .onTick(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue = newValue else { return }
            self = .onTick(newValue)
        }
    }
}
extension Action: EmptyInitializable {
    init() { self = .none }
}

struct ContentView: StoreView {
    let store: Store<AppState, Action>
    
    var body: some View {
        VStack {
            Text("Hello World")
            Text(verbatim: "\(self.foo)")
            Toggle(isOn: self.foo { _ in .none }) {
                EmptyView()
            }
            Button(action: {
                self.onTick(Date())
                }) {
                Text("toggle")
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .just(AppState()))
    }
}
#endif
