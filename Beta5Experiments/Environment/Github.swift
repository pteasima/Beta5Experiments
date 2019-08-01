import Foundation
import Combine

private let token = "3afeb0a0592b48eec18873b6bd3413352302cb9c"

struct Github {
    var getGists: () -> AnyPublisher<(), Never> = {
        return Just(()).eraseToAnyPublisher()
    }
}

