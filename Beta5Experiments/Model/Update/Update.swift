import Foundation
import Combine

extension AppState: Application {
    var environment: Environment { .init() }

    enum Action {
        case none
        case gistListAppear
        case fetchedGists(Result<[Gist], Error>)
        case selectGist(id: Gist.ID)
        case gist(id: Gist.ID, gistAction: GistAction)
        case fetchedFile(contents: Result<String, Error>, fromURL: URL)
    }
    
    enum GistAction {
        case delete
        case disappear
        case didDelete
    }

    mutating func reduce(_ action: Action) -> [Effect<Action, Environment>] {
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
                self.gists = gists.map { GistModel(gist: $0) }
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
        case let .gist(id: id, gistAction: gistAction):
            switch gistAction {
            case .delete:
                selectedGistID = nil
                gists.modify(where: { $0.id == id }) {
                    $0.state = .deleting
                }
                return [
                    +(\.github.login, "myusername", { _ in .none }),
                    +{ $0.github.bar(stringParam: "bar").map { _ in .none } },
//                    Cmd(\.http.delete, HTTP.DeleteParams(url: URL(string: "https://api.github.com/gists/\(id.rawValue)")!, headers: ["Authorization" : "token d51bd98a7e8cd9838d13b2078a0f7851194ef96c"])) { (_: Data) in
//                        .gist(id: id, msg: .didDelete)
//                    }
                ]
            case .disappear:
                selectedGistID = nil
                return []
            case .didDelete:
                gists.removeAll { $0.id == id }
                return []
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
            .init(\.clock.repeatedTimer, 5.0, \.noAction)
        ]
    }

}


extension Date {
    var noAction: AppState.Action { return .none }
}
