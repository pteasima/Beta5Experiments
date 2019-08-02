import Foundation
import Combine
#if canImport(XCTest)
    import XCTest
#endif

// To stess-test the application, the root scene displays a clock that updates every 5 seconds.
// This may help catch some bugs where UI is out of sync or breaks after a store update.
struct Clock {
    var repeatedTimer: (TimeInterval) -> AnyPublisher<Date, Never> = { _ in
        Empty(completeImmediately: true).breakpoint(receiveSubscription: {
            print($0)
            #if canImport(XCTest)
            XCTAssert(false)
            #endif
            return true
        }).eraseToAnyPublisher()
    }
}
extension Clock {
    static let live: Clock = .init(repeatedTimer: { interval in
        let subject = PassthroughSubject<Date, Never>()
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            subject.send(timer.fireDate)
        }
        return subject.eraseToAnyPublisher()
    })
}
