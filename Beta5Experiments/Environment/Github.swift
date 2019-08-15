import Foundation
import Combine
//this was token to my personal account but Ive revoked it
private let token = "3afeb0a0592b48eec18873b6bd3413352302cb9c"

struct Github {
  var login: (String) -> AnyPublisher<Data, Never> = unimplemented
  var getGists: () -> AnyPublisher<Result<[Gist], Error>, Never> = {
    Just(.success([
      Gist(
        id: .init(rawValue: "1"),
        description: "first",
        files: []
      ),
      Gist(
        id: .init(rawValue: "2"),
        description: "second",
        files: []
      ),
      Gist(
        id: .init(rawValue: "3"),
        description: "third",
        files: []
      ),
    ])).eraseToAnyPublisher()
  }
  var deleteGist: (Gist.ID) -> AnyPublisher<Result<(), Error>, Never> = unimplemented
  
}
extension Github {
  static let live: Github = .init(
    getGists: {
      request(endpoint: .gists)
  },
  deleteGist: { id in
    request(.delete, endpoint: .gist(id))
      .map { (_: Result<Unit, Error>) in .success(()) }
      .eraseToAnyPublisher()
  }
  )
}

private enum HTTPMethod: String {
  case get = "GET"
  case delete = "DELETE"
}

// Im not sure if this is how you properly model endpoints. Might need to checkout pointfreeco's PartialIsos (whatever that is) again. Probably out of scope for this toy app.
private enum Endpoint {
  case gists
  case gist(Gist.ID)
  
  var path: String {
    switch self {
    case .gists:
      return "gists"
    case let .gist(id):
      return "gists/\(id.rawValue)"
    }
  }
}
private struct SimpleError: Error {
  var errorDescription: String
}

private func request<Output: Decodable>(
  _ method: HTTPMethod = .get,
  endpoint: Endpoint
) -> AnyPublisher<Result<Output, Error>, Never> {
  var request = URLRequest(url: URL(string: "https://api.github.com/\(endpoint.path)")!)
  request.httpMethod = method.rawValue
  request.allHTTPHeaderFields = ["Authorization" : "token d51bd98a7e8cd9838d13b2078a0f7851194ef96c"]
  return URLSession.shared.dataTaskPublisher(for: request)
    .mapError { $0 }
    .flatMap { data, response -> AnyPublisher<Output, Error> in
      switch (response as? HTTPURLResponse)?.statusCode {
      case (200...299)?:
        do {
          return Just(try JSONDecoder().decode(Output.self, from: data))
            .mapError(absurd)
            .eraseToAnyPublisher()
        } catch {
          return Fail(error: error)
            .eraseToAnyPublisher()
        }
      default:
        return Fail(error: SimpleError(errorDescription: "an error occured"))
          .eraseToAnyPublisher()
      }
  }
  .map(Result.success)
  .catch { Just(.failure($0)) }
  .eraseToAnyPublisher()
}
