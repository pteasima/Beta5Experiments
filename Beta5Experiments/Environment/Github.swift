import Foundation
import Combine
#if canImport(XCTest)
    import XCTest
#endif

private let token = "3afeb0a0592b48eec18873b6bd3413352302cb9c"

struct Github {
    var login: (String) -> AnyPublisher<Data, Never> = { _ in
        Empty(completeImmediately: true).breakpoint(receiveSubscription: {
            print($0)
            #if canImport(XCTest)
            XCTAssert(false)
            #endif
            return true
        }).eraseToAnyPublisher()
    }
    var getGists: () -> AnyPublisher<(), Never> = {
        Empty(completeImmediately: true).breakpoint(receiveSubscription: {
            print($0)
            #if canImport(XCTest)
            XCTAssert(false)
            #endif
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
        getGists: {
            Just(()).eraseToAnyPublisher()
    })
}
/*
// if you want this non-KeyPath-based API you have to create an extra protocol (HasGithub)
// its probably useful since you can use generics and still refer to Github's var internally
// alternatively, we could disallow this and force
protocol HasGithub {
    var github: Github { get }
}
extension Environment: HasGithub { }
extension Effect where Environment: HasGithub {
    static func login(_ username: String/*, action: @escaping (Data) -> Action*/) -> Effect {
        .init { environment in
            
            Empty(completeImmediately: true)
        }
    }
}
*/
