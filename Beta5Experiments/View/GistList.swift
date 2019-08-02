import SwiftUI
import Combine

struct GistList: StoreView {
    var store: Store<AppState, AppState.Action>
    
    var body: some View {
        Group {
            if self.error != nil {
                Text(verbatim: self.error!)
                    .lineLimit(nil)
            }
            else {
//
                List {
                    ForEach(self.gists, id: \.id) { gist in
                        Group {
                            gist.state.idle.map {
                                VStack {
                                Button(action: { self.selectGist(gist.id) }) {
                                    Text(verbatim: gist.description)
                                }
                                Text(verbatim: gist.filesDisplayString)
                                    .foregroundColor(.gray)
                            }
                        }
                            gist.state.deleting.map { Text("Deleting") }
                        }
                    }
                    .onDelete { deletedIndices in
                        deletedIndices.compactMap {
                            self.gists[safe: $0]?.id
                        }
                            .forEach { self.gist($0, .delete) } //we shouldnt dispatch multiple times but afaik there will always be just one deletedIndex
                        
                    }
                }
                .navigationBarTitle(Text("Gists"))
//                    .background(Navigator<GistModel, Gist.ID, GistDetail>(
//                        program: self.program,
//                        selector: { model in
//                            guard let gist = model.selectedGist
//                                else { return nil }
//                            return (gist.id, gist)
//                    },
//                        msgTransform: (Msg.gist),
//                        build: GistDetail.init
//                    ))
            }
        }
        .onAppear { /*self.dispatch(.gistListAppear)*/ }
    }
}

import Gen

#if DEBUG
struct GistList_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            GistList(store: .just(AppState(
                gists: [
                    GistState(gist: Gist(
                        id: .init(rawValue: "1"),
                        description: "first",
                        files: []
                    )),
                    GistState(gist: Gist(
                        id: .init(rawValue: "2"),
                        description: "second",
                        files: []
                    )),
                ]
            )))
        }
    }
}
#endif
