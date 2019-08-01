//
//  ContentView.swift
//  Beta5Experiments
//
//  Created by Petr Šíma on 31/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: /*Store*/View {
    var store: Store<AppState, AppState.Action>
    
    var body: some View {
        VStack {
            Text("Hello World")
//            Text(verbatim: "\(self.dateText)")
//            Toggle(isOn: self.isToggleOn { .toggle($0) }) {
//                EmptyView()
//            }
//            Button(action: {
//                self.onTick(Date())
//            }) {
//                Text("Refresh Date")
//            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .application(AppState()))
    }
}
#endif

