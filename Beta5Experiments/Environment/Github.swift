import Foundation
import Combine

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
}
extension Github {
    static let live: Github = .init(
      getGists: {
        request(endpoint: .gists)
    })
}

private enum HTTPMethod: String {
  case get = "GET"
  case delete = "DELETE"
}

private enum Endpoint: String {
  case gists
}
private struct SimpleError: Error {
  var errorDescription: String
}

private func request<O: Decodable>(
  _ method: HTTPMethod = .get,
  endpoint: Endpoint
  ) -> AnyPublisher<Result<O, Error>, Never> {
  var request = URLRequest(url: URL(string: "https://api.github.com/\(endpoint.rawValue)")!)
  request.httpMethod = method.rawValue
  request.allHTTPHeaderFields = ["Authorization" : "token d51bd98a7e8cd9838d13b2078a0f7851194ef96c"]
  return URLSession.shared.dataTaskPublisher(for: request)
    .mapError { $0 }
    .flatMap { data, response -> AnyPublisher<O, Error> in
      switch (response as? HTTPURLResponse)?.statusCode {
      case (200...299)?:
        do {
          return Just(try JSONDecoder().decode(O.self, from: data))
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
