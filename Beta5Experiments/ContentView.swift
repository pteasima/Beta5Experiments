//
//  ContentView.swift
//  Beta5Experiments
//
//  Created by Petr Šíma on 31/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import SwiftUI
import Combine

final class AnyObservedObject<Model>: ObservableObject {
    init(model: Model) { self.model = model }
    @Published var model: Model
}

@propertyWrapper struct Store<Model>: DynamicProperty {
    @ObservedObject var projectedValue: AnyObservedObject<Model>
    var wrappedValue: Model {
        get {
            projectedValue.model
        }
        nonmutating set {
            projectedValue.model = newValue
        }
    }
}

struct AppState {
    var foo: Bool = true
}


struct ContentView: View {
    @Store var store: AppState
    
    var body: some View {
        VStack {
            Text("Hello World")
            Text(verbatim: "\(store.foo)")
            Toggle(isOn: _store.$projectedValue.model.foo) {
                EmptyView()
            }
//            Button(action: { self.store.foo.toggle() }) {
//                Text("toggle")
//            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(projectedValue: AnyObservedObject(model: AppState())))
    }
}
#endif
