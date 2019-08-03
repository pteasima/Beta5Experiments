import Tagged

@dynamicMemberLookup struct GistState: Lookup {
    enum Status: Equatable {
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
    var status: Status = .idle
    
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

extension GistState {
    var content: String? {
        
        files.compactMap {
            $0.content.result?.success
        }
        .joined(separator: "\n")
    }
}

@dynamicMemberLookup struct FileModel: Lookup {
    static let model = \Self.file
    private(set) var file: File
    var content: RemoteData<String, Error> = .notRequested
}
