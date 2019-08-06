import Foundation
import Combine

extension AppState: Application {
  enum Action: EmptyInitializable {
    init() { self = .none }
    
    case none
    case gistListAppear
    case fetchedGists(Result<[Gist], Error>)
    case selectGist(id: Gist.ID)
    case unselectGist
    case gist(id: Gist.ID, gistAction: GistState.Action)
    case fetchedFile(contents: Result<String, Error>, fromURL: URL)
    
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
    
    var gistListAppear: Void? {
      get {
        guard case .gistListAppear = self else { return nil }
        return ()
      }
      set {
        guard let _ = newValue else { return }
        self = .gistListAppear
      }
    }
    
    var fetchedGists: Result<[Gist], Error>? {
      get {
        guard case let .fetchedGists(value) = self else { return nil }
        return value
      }
      set {
        guard let newValue = newValue else { return }
        self = .fetchedGists(newValue)
      }
    }
    
    var selectGist: Gist.ID? {
      get {
        guard case let .selectGist(value) = self else { return nil }
        return value
      }
      set {
        guard let newValue = newValue else { return }
        self = .selectGist(id: newValue)
      }
    }
    var unselectGist: Void? {
      get {
        guard case .unselectGist = self else { return nil }
        return ()
      }
      set {
        guard let _ = newValue else { return }
        self = .unselectGist
      }
    }
    
    var gist: (Gist.ID, GistState.Action)? {
      get {
        guard case let .gist(value) = self else { return nil }
        return value
      }
      set {
        guard let newValue = newValue else { return }
        self = .gist(id: newValue.0, gistAction: newValue.1)
      }
    }
    
    var fetchedFile: (Result<String, Error>, URL)? {
      get {
        guard case let .fetchedFile(value) = self else { return nil }
        return value
      }
      set {
        guard let newValue = newValue else { return }
        self = .fetchedFile(contents: newValue.0, fromURL: newValue.1)
      }
    }
    
  }
  
  mutating func reduce(_ action: Action) -> [Effect<Action, Environment>] {
    print("REDUCE", action)
    switch action {
    case .none:
      return []
    case .gistListAppear:
      return [
        //users/pteasima
        //                Cmd(\.http[decodingResultOf: \.get], HTTP.GetParams(url: URL(string: "https://api.github.com/gists")!, headers: ["Authorization" : "token d51bd98a7e8cd9838d13b2078a0f7851194ef96c"])) { .fetchedGists($0) }
      ]
    case let .fetchedGists(result):
      switch result {
      case let .success(gists):
        self.gists = gists.map { GistState(gist: $0) }
        error = nil
      case let .failure(error):
        self.error = error.localizedDescription
      }
      return []
    case let .selectGist(id: id):
      selectedGistID = id
      
      guard let selectedGist = selectedGist
        else { assertionFailure(); return [] }
      return []
      //            return selectedGist.files
      //                .map { $0.url }
      //                .map { url in
      //                    Cmd(\.http.get, HTTP.GetParams(url: url)) {
      //                        .fetchedFile(contents: .success(String(decoding: $0, as: UTF8.self)), fromURL: url)
      //                    }
    //            }
    case .unselectGist:
      selectedGistID = nil
      return []
    case let .gist(id: id, gistAction: gistAction):
      switch gistAction {
      case .none: return []
      case .delete:
        selectedGistID = nil
        gists.modify(where: { $0.id == id }) {
          $0.status = .deleting
        }
        return [
          
//          +{ $0.github.bar(stringParam: "bar").map { _ in .none } } >> effectToCancel,
//          +(\.github.login, "myusername", { _ in .none }) >> effectToCancel,
//          +{ $0.github.bar(stringParam: "bar").map { _ in .none } },
//          -(effectToCancel)
          //                    Cmd(\.http.delete, HTTP.DeleteParams(url: URL(string: "https://api.github.com/gists/\(id.rawValue)")!, headers: ["Authorization" : "token d51bd98a7e8cd9838d13b2078a0f7851194ef96c"])) { (_: Data) in
          //                        .gist(id: id, msg: .didDelete)
          //                    }
        ]
      }
      
    case let .fetchedFile(contents: result, fromURL: url):
      gists.modify {
        $0.files.modify(where: { $0.url == url }) {
          $0.content = .result(result)
        }
      }
      return []
    }
  }
  
  func subscriptions() -> [SubscriptionEffect<Action, Environment>] {
    [
//      .init(\.clock.repeatedTimer, 5.0, \.noAction)
    ]
  }
  
  var initialEffects: [Effect<AppState.Action, Environment>] {
    [
      +(\.github.getGists, "dummyParam", { .fetchedGists($0) })
    ]
  }
}

extension GistState {
  enum Action: EmptyInitializable {
    init() { self = .none}
    
    case none
    case delete
    
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
    var delete: Void? {
      get {
        guard case .delete = self else { return nil }
        return ()
      }
      set {
        guard let _ = newValue else { return }
        self = .delete
      }
    }
  }
}

extension Date {
  var noAction: AppState.Action { return .none }
}

