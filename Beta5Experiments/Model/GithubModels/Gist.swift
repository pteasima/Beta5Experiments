import Tagged

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

extension Gist {
    var filesDisplayString: String { files.map { $0.filename }.joined(separator: ", ") } //placeholder
}
