import Foundation
import Combine
import Tagged

// ElmProgram conforms to this to allow effect cancellation and possibly other internal program tasks in the future
protocol EffectManager {
    func cancelEffect(id: Tagged<EffectManager, String>)
}

struct Effect<Action, Environment> {
    let perform: (EffectManager, Environment) -> AnyPublisher<Action, Never>
    init<P: Publisher>(perform: @escaping (Environment) -> P) where P.Output == Action, P.Failure == Never {
        self.perform = { _, env in perform(env).eraseToAnyPublisher() }
    }
    
    private init(cancel: Tagged<EffectManager, String>) {
        self.perform = { effManager, _ in
            Empty<Action, Never>(completeImmediately: true)
                .handleEvents(receiveSubscription: { _ in
                    
                }).eraseToAnyPublisher()
        }
    }
}
extension Effect {
    public init<Input, Output, P: Publisher>(_ keyPath: KeyPath<Environment, (Input) -> P>, _ input: Input, _ transform: @escaping (Output) -> Action) where P.Output == Output, P.Failure == Never {
        self.init { effects in
            effects[keyPath: keyPath](input).map(transform)
        }
    }
}
