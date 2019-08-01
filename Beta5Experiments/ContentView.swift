//
//  ContentView.swift
//  Beta5Experiments
//
//  Created by Petr Šíma on 31/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import SwiftUI
import Combine

final class StateObject<State>: ObservableObject {
    init(state: State) { self.state = state }
    @Published var state: State
}

@dynamicMemberLookup final class Store<State, Action> {
    @ObservedObject private var stateObject: StateObject<State>
    let dispatch: (Action) -> ()
    
    private var strongReferences: [Any] = [] //used to retain disposables and Program, no need to keep type of either
    
    //this generic version segfaults at callsite, we need to typeErase for now
//    private init<P: Publisher>(initialState: State, dispatch: @escaping (Action) -> Void, willChange: P) where P.Output == State, P.Failure == Never { }

    private init(initialState: State, dispatch: @escaping (Action) -> Void, willChange: AnyPublisher<State, Never>) {
        stateObject = StateObject(state: initialState)
        self.dispatch = dispatch
        strongReferences.append(willChange.assign(to: \.state, on: stateObject))
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
}

struct AppState {
    var foo: Bool = true
}

struct ContentView: View {
    let store: Store<AppState, ()>
    
    var body: some View {
        VStack {
            Text("Hello World")
            Text(verbatim: "\(store.foo)")
            Toggle(isOn: store.foo { _ in }) {
                EmptyView()
            }
            Button(action: { self.store.dispatch(()) }) {
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
