import Foundation
import Tagged

struct AppState {
    var effectToCancel: EffectManager.EffectID?
    var selectedGistID: Gist.ID? //TODO: model this with ListWithSingleSelection?
    var gists: [GistState] = []
    var error: String?
}

extension AppState {
    var selectedGist: GistState? {
        get {
            selectedGistID.flatMap { id in gists.first { $0.id == id } }
        }
    }
}
