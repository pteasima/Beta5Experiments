import Foundation
import Tagged

struct AppState {
    var selectedGistID: Gist.ID? //TODO: model this with ListWithSingleSelection?
    var gists: [GistModel] = [
    ]
    var error: String? = "loading"
}

extension AppState {
    var selectedGist: GistModel? {
        get {
            selectedGistID.flatMap { id in gists.first { $0.id == id } }
        }
    }
}

@dynamicMemberLookup struct GistModel: Lookup {
    enum State: Equatable {
        case idle
        case deleting
//        case deleteError(Error)
        
        var idle: ()? {
            guard case .idle = self else { return nil }
            return ()
        }
        var deleting: ()? {
            guard case .deleting = self else { return nil }
            return ()
        }
    }
    var state: State = .idle
    
    static let model = \Self.gist
    private(set) var gist: Gist
    init(gist: Gist) {
        self.gist = gist
        files = gist.files.map { FileModel(file: $0) }
    }
    var files: [FileModel] {
        didSet {
            gist.files = files.map { $0.file }
        }
    }
}

@dynamicMemberLookup struct FileModel: Lookup {
    static let model = \Self.file
    private(set) var file: File
    var content: RemoteData<String, Error> = .notRequested
}

struct Gist: Codable {
    typealias ID = Tagged<Gist, String>
    let id: ID
    var description: String
    var files: [File]
}
extension Gist {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(ID.self, forKey: .id),
            description: try container.decode(String.self, forKey: .description),
            files: try Array(container.decode([String: File].self, forKey: .files).values)
        )
    }
}

extension GistModel {
    var content: String? {
        
        files.compactMap {
            $0.content.result?.success
        }
        .joined(separator: "\n")
    }
}

extension Gist {
    var filesDisplayString: String { files.map { $0.filename }.joined(separator: ", ") } //placeholder
}

struct File: Codable {
    var filename: String
    var url: URL
    
    enum CodingKeys: String, CodingKey {
        case filename
        case url = "raw_url"
    }
}

//#if DEBUG
//import SwiftUI
//struct ModelPreview: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ScriptView { log in
//                log("nothing to see here")
//                var strings = ["foo", "bar"]
//                strings.modify {
//                    $0 = "baz"
//                }
//                log("\(strings)")
//            }
//        }
//    }
//}
//#endif
