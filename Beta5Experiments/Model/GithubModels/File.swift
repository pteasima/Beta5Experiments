import Foundation

struct File: Codable {
    var filename: String
    var url: URL
    
    enum CodingKeys: String, CodingKey {
        case filename
        case url = "raw_url"
    }
}
