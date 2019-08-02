import Foundation
import Combine
//#if canImport(XCTest)
//    import XCTest
//#endif

private let token = "3afeb0a0592b48eec18873b6bd3413352302cb9c"

struct Github {
    var login: (String) -> AnyPublisher<Data, Never> = { _ in
        Empty(completeImmediately: true).breakpoint(receiveSubscription: {
            print($0)
//            #if canImport(XCTest)
//            XCTAssert(false)
//            #endif
            return true
        }).eraseToAnyPublisher()
    }
    var getGists: (String) -> AnyPublisher<Result<[Gist], Error>, Never> = { _ in
        Empty(completeImmediately: true).breakpoint(receiveSubscription: {
            print($0)
//            #if canImport(XCTest)
//            XCTAssert(false)
//            #endif
            return true
        }).eraseToAnyPublisher()
    }
    // we can support methods, even generic ones
    func bar(stringParam: String) -> AnyPublisher<Int, Never> {
        Empty<Int, Never>().eraseToAnyPublisher()
    }
    func foo<T>(_ t: T.Type = T.self) -> AnyPublisher<T, Never> {
        Empty<T, Never>().eraseToAnyPublisher()
    }
}
extension Github {
    static let live: Github = .init(
        getGists: { _ in
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
//                Gist(
//                    id: .init(rawValue: "3"),
//                    description: "third",
//                    files: []
//                ),
            ])).eraseToAnyPublisher()
    })
}
