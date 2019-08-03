//
//  GistDetail.swift
//  Gister
//
//  Created by Petr Šíma on 01/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import SwiftUI
import Combine

struct GistDetail: StoreView {
    var store: Store<GistState, GistState.Action>
    var body: some View {
        VStack {
            Text(verbatim: self.description)
                .lineLimit(nil)
          Button(action: { self.delete() }) {
                Text("delete")
            }
            Text(verbatim: self.filesDisplayString)

            self.content.map(Text.init(verbatim:))
        }
    }
}

#if DEBUG
struct GistDetail_Previews: PreviewProvider {
    static var previews: some View {
        GistDetail(store: .just(GistState(gist: Gist(
            id: .init(rawValue: ""),
            description: "description ok it works",
            files: [
                File(filename: "test.swift", url: URL(string: "www.google.com")!),
                File(filename: "bar.swift", url: URL(string: "www.google.com")!),
        ]))))
    }
}
#endif
