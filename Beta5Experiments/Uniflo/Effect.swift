import Foundation
import Combine

struct Effect<Action, Environment> {
    let perform: (Environment) -> AnyPublisher<Action, Never>
    init<P: Publisher>(perform: @escaping (Environment) -> P) where P.Output == Action, P.Failure == Never {
        self.perform = { perform($0).eraseToAnyPublisher() }
    }
}
extension Effect {
    public init<Input, Output, P: Publisher>(_ keyPath: KeyPath<Environment, (Input) -> P>, _ input: Input, _ transform: @escaping (Output) -> Action) where P.Output == Output, P.Failure == Never {
        self.init { effects in
            effects[keyPath: keyPath](input).map(transform)
        }
    }
}
