import Foundation
import Combine
import Tagged

// ElmProgram conforms to this to allow effect cancellation and possibly other internal program tasks in the future
protocol EffectManager {
    typealias EffectID = Tagged<EffectManager, String>
    func cancelEffect(id: Tagged<EffectManager, String>)
}

// TODO: I jumped through hoops to enable command cancellation but now Im thinking: If it needs to be tracked in state, shouldnt it just be a Subscription? These are not equivalent (for cancellable command you just store the ID, whereas to even create the subscription you need to store more data), but I think they can achieve same results. I think Elm was considering adding command cancellation but need to see how they ended up deciding. I would gladly take explaining to newbies why X needs to be a Subscription over introducing ambiguity.
struct Effect<Action, Environment> {
    let id: EffectManager.EffectID
    let perform: (EffectManager, Environment) -> AnyPublisher<Action, Never>
    fileprivate init<P: Publisher>(perform: @escaping (Environment) -> P) where P.Output == Action, P.Failure == Never {
        id = .init(rawValue: UUID().uuidString)
        self.perform = { _, env in perform(env).eraseToAnyPublisher() }
    }
    
    fileprivate init(cancel effectID: Tagged<EffectManager, String>) {
        // technically theres no reason to support cancelling a cancel effect (its always synchronous)
        // but we return a proper id cause why not
        id = .init(rawValue: UUID().uuidString)
        self.perform = { effManager, _ in
            Empty<Action, Never>(completeImmediately: true)
                .handleEvents(receiveSubscription: { _ in
                    effManager.cancelEffect(id: effectID)
                }).eraseToAnyPublisher()
        }
    }
    
    // this is convencience to easily store EffectID in State for later cancellation
    static func >>(effect: Effect, id: inout EffectManager.EffectID?) -> Effect {
        id = effect.id
        return effect
    }
}

// MARK: add effect

// this is the "raw-closure" syntax
// you can return an arbitrary publisher
prefix func +<Action, Environment, P: Publisher>(perform: @escaping (Environment) -> P) -> Effect<Action, Environment> where P.Output == Action, P.Failure == Never {
    Effect { environment in
        perform(environment)
    }
}
// this is the "keyPath-input-transform" syntax
// prefer this for the usual service vars
// it doesnt give you freedom to return arbitrary publisher, which is a good thing
// this cannot be used to call a method (neither normal nor generic) on a service
prefix func +<Action, Environment, Input, Output, P: Publisher>(params: (KeyPath<Environment, (Input) -> P>, Input, (Output) -> Action)) -> Effect<Action, Environment> where P.Output == Output, P.Failure == Never {
    Effect { environment in
        environment[keyPath: params.0](params.1).map(params.2)
    }
}
// variant of "keyPath-input-transform" with no input
prefix func +<Action, Environment, Output, P: Publisher>(params: (KeyPath<Environment, () -> P>, (Output) -> Action)) -> Effect<Action, Environment> where P.Output == Output, P.Failure == Never {
    Effect { environment in
        environment[keyPath: params.0]().map(params.1)
    }
}

// we briefly had a "keyPathToService + serviceMethod + input + transform" syntax
// it was getting crazy with 6 generic params
// wasnt much safer than raw anyway (could still supply arbitrary closure in place of "serviceMethod")
// prefer raw-closure syntax when you cant use keyPath-input-transform syntax

// MARK: cancel effect

prefix func -<Action, Environment>(_ id: EffectManager.EffectID) -> Effect<Action, Environment> {
    Effect(cancel: id)
}

// this is convenience to easily cancel an effect and nil-out a state property that tracked its id
prefix func -<Action, Environment>(_ id: inout EffectManager.EffectID?) -> Effect<Action, Environment> {
    let effect: Effect<Action, Environment>
    if let id = id {
       effect  = Effect(cancel: id)
    } else {
        effect = Effect { _ in Empty(completeImmediately: true) }
    }
    id = nil
    return effect
}
