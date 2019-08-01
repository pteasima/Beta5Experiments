import Foundation
import Combine

// To stess-test the application, the root scene displays a clock that updates every 5 seconds.
// This may help catch some bugs where UI is out of sync or breaks after a store update.
struct Clock {
    var repeatedTimer: (TimeInterval) -> AnyPublisher<Date, Never> = { interval in
        let subject = PassthroughSubject<Date, Never>()
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            subject.send(timer.fireDate)
        }
        return subject.eraseToAnyPublisher()
    }
}
