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

@dynamicMemberLookup struct Store<State, Action>: DynamicProperty {
    @ObservedObject private var stateObject: StateObject<State>
    var dispatch: (Action) -> ()
    
    private init(state: State, dispatch: @escaping (Action) -> Void) {
        stateObject = StateObject(state: state)
        self.dispatch = dispatch
    }
    static func just(_ state: State) -> Store {
        self.init(state: state, dispatch: {
            print($0)
        })
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
