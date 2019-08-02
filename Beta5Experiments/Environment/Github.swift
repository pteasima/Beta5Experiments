import Foundation
import Combine
#if canImport(XCTest)
    import XCTest
#endif

private let token = "3afeb0a0592b48eec18873b6bd3413352302cb9c"

struct Github {
    var login: () -> AnyPublisher<(), Never> = {
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
}
extension Github {
    static let live: Github = .init(
        getGists: {
            Just(()).eraseToAnyPublisher()
    })
}
