import SwiftUI
import Combine

struct GistList: StoreView {
  var store: Store<AppState, AppState.Action>
//  @State var selectedFirstID: Gist.ID?
  
  var body: some View {
    
    Group {
      if self.error != nil {
        Text(verbatim: self.error!)
          .lineLimit(nil)
      }
      else {
        List {
          ForEach(self.gists, id: \.id) { gist in
            Group {
              // !!! NAVIGATION IS STILL SERIOUSLY BROKEN
              // I believe NavigatioLink is still bugged here. the last value read from the binding is false, yet screen gets pushed again once. After second pop its fixed.
              // It also breaks if I use Binding to @State locally, so hopefully no bug in my Store
              NavigationLink(destination: GistDetail(
                store: self.store
                  .filterMap(initialState: gist, transform: { $0.gists.first { $0.id == gist.id } })
                  .pullback { .gist(id: gist.id, gistAction: $0) }
                ), tag: gist.id, selection: self.selectedGistID { (id: Gist.ID?) -> Action in
                  print(id)
                  return id.map(Action.selectGist) ?? .unselectGist
                }
                //use this to debug on a local property
                //                    Binding(get: {
                //                      let result = self.selectedFirstID
                //                      print("get", result)
                //                      return result
                ////                      .init(rawValue: 1)
                //                     }, set: {
                //                      print("set", $0)
                //                      self.selectedFirstID = $0
              ) {
                VStack(alignment: .leading) {
                  Text(gist.description)
                  gist.status.idle.map {
                    Text(verbatim: gist.filesDisplayString)
                      .foregroundColor(.gray)
                  }
                  gist.status.deleting.map { Text("deleting...") }
                }
              }
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
      }
    }
    .onAppear { self.gistListAppear() }
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

private let playground: () -> Void = {
  let appState = AppState()
  let gist = appState.gists[0]
  var store : Store<AppState, AppState.Action> = .just(appState)
  let x = store.filterMap(initialState: gist, transform: { $0.gists.first { $0.id == gist.id } })
}
