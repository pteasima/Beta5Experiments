import SwiftUI
import Combine

struct Environment {}
struct Unit: EmptyInitializable { }

protocol Application {
    associatedtype Action = Never
    associatedtype Environment = Unit
    var environment: Environment { get }
    var initialEffects: [Effect<Action, Environment>] { get }
    mutating func reduce(_ action: Action) -> [Effect<Action, Environment>]
    func subscriptions() -> [SubscriptionEffect<Action, Environment>]
}
extension Application {
    var initialEffects: [Effect<AppState.Action, Environment>] {
        []
    }
    func reduce(_ action: AppState.Action) -> [Effect<AppState.Action, Environment>] {
        print("using default reduce implementation for application \(self), action: \(action)")
        return []
    }
    func subscriptions() -> [SubscriptionEffect<AppState.Action, Environment>] {
        []
    }
}
extension Application where Environment: EmptyInitializable {
    var environment: Environment { .init() }
}
protocol EmptyInitializable {
    init()
}

final class StateObject<State>: ObservableObject {
    init(state: State) { self.state = state }
    @Published var state: State
}

@dynamicMemberLookup struct Store<State, Action>: DynamicProperty {
    @ObservedObject private var stateObject: StateObject<State>
    let dispatch: (Action) -> ()
    
    private var strongReferences: [Any] = [] //used to retain Cancellables and Application, no need to track type of either
    
    //this generic version segfaults at callsite, we need to typeErase for now
    //    private init<P: Publisher>(initialState: State, dispatch: @escaping (Action) -> Void, willChange: P) where P.Output == State, P.Failure == Never { }
    
    private init(initialState: State, dispatch: @escaping (Action) -> Void, willChange: AnyPublisher<State, Never>) {
        stateObject = StateObject(state: initialState)
        self.dispatch = dispatch
        strongReferences.append(willChange
            .breakpoint(receiveOutput: {
                print($0)
                return false
            })
            .assign(to: \.state, on: stateObject)
        )
    }
    
    static func application<Environment>(environment: Environment, initialState: State, initialEffects: [Effect<Action, Environment>] = [], reduce: @escaping (inout State, Action) -> [Effect<Action, Environment>] = {_,_ in []}, subscriptions: @escaping (State) -> [SubscriptionEffect<Action, Environment>] = { _ in [] }) -> Store {
        
        let program = ElmProgram<State, Action, Environment>(initialState: initialState, initialEffects: initialEffects, update: reduce, subscriptions: subscriptions, effects: environment)
        var store = Store(initialState: program.state, dispatch: program.dispatch, willChange: program.willChange.eraseToAnyPublisher())
        store.strongReferences.append(program)
        
        return store
    }
    
    static func just(_ state: State) -> Store {
        self.init(initialState: state, dispatch: {
            print($0)
        }, willChange: Empty(completeImmediately: true).eraseToAnyPublisher())
    }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> Subject {
        stateObject.state[keyPath: keyPath]
    }
    
    subscript<Subject>(dynamicMember keyPath: KeyPath<State, Subject>) -> (@escaping (Subject) -> Action) -> Binding<Subject> {
    { transform in
        Binding(get: {
            self[dynamicMember: keyPath]
        }, set: { newValue in
            self.dispatch(transform(newValue))
        })
        }
    }
    subscript<ActionParam>(dynamicMember keyPath: WritableKeyPath<Action, ActionParam?>) -> (ActionParam) -> Void
        where Action: EmptyInitializable {
            {
                var action = Action()
                action[keyPath: keyPath] = $0
                self.dispatch(action)
            }
    }
}
extension Store where State: Application, State.Action == Action {
    static func application(_ initialState: State) -> Store {
        self.application(environment: initialState.environment, initialState: initialState, initialEffects: initialState.initialEffects, reduce: { $0.reduce($1) }, subscriptions: { $0.subscriptions() })
    }
}

fileprivate final class ElmProgram<State, Action, Environment> {
    private(set) lazy var dispatch: (Action) -> Void = {
        self._dispatch($0)
    }
    let willChange = PassthroughSubject<State, Never>()
    private var _dispatch: ((Action) -> Void)!
    private var draftState: State
    private(set) var state: State
    private var isIdle = true
    private var queue : [Action] = []
    private var subscriptions: [(subscription: SubscriptionEffect<Action, Environment>, cancellable: AnyCancellable)] = []//subscriptions we've already fired and may want to cancel
    
    private var effectCancellables: [AnyCancellable] = []
    init(initialState: State, initialEffects: [Effect<Action, Environment>], update: @escaping (inout State, Action) -> [Effect<Action, Environment>], subscriptions: @escaping (State) -> [SubscriptionEffect<Action, Environment>], effects: Environment) {
        draftState = initialState
        state = initialState
        
        //TODO: run the initial effects, we currently ignore them
        
        _dispatch = { [weak self] msg in
            let dispatchOnMainThread = { [weak self] in
                guard let self = self else { assertionFailure("if I properly managed all cancellables, a dispatch on a dead Program would never happen"); return }
                self.queue.append(msg)
                if self.isIdle { //only start the processing while-loop once. If not idle, then this is a recursive dispatch and we just need to enqueue it.
                    self.isIdle = false
                    defer { self.isIdle = true }
                    
                    while !self.queue.isEmpty {
                        let currentMsg = self.queue.removeFirst()
                        let effs = update(&self.draftState, currentMsg)
                        effs.forEach {
                            var cancellable: AnyCancellable?
                            var completedAlready = false
                            cancellable = AnyCancellable($0.perform(effects)
                                .sink(receiveCompletion: { [weak self] _ in
                                    //effectCancellables shouldnt grow indefinitelly, so we remove the cancellable on completion
                                    // TODO: removeFirst(where:)
                                    // TODO: this can still run on a background thread (only in dispatch do we switch to main thread), is this safe?
                                    if let cancellable = cancellable {
                                        self?.effectCancellables.removeAll { $0 === cancellable }
                                    }
                                    completedAlready = true
                                    },receiveValue: self.dispatch))
                            if !completedAlready { //only append it unless it completed synchronously (Afaik you cant tell from the cancellable if its still alive)
                                self.effectCancellables.append(cancellable!)
                            }
                        }
                        
                        let subs = subscriptions(self.state)
                        // we cant do a collection.difference here, since that can produce .inserts and .removes for reordering
                        // we dont care about order, just cancel and remove old ones and append new ones
                        self.subscriptions.forEach { oldSub in
                            if !subs.contains(oldSub.subscription) {
                                oldSub.cancellable.cancel()
                                // TODO: removeFirst(where:)
                                self.subscriptions.removeAll { $0.subscription == oldSub.subscription }
                            }
                        }
                        subs.forEach { newSub in
                            if !self.subscriptions.contains(where: { $0.subscription == newSub }) {
                                let cancellable = AnyCancellable(newSub.perform(effects).sink(receiveValue: self.dispatch))
                                self.subscriptions.append((newSub, cancellable))
                            }
                        }
                    }
                    
                    self.willChange.send(self.draftState)
                    self.state = self.draftState
                }
            }
            if Thread.isMainThread {
                dispatchOnMainThread()
            } else {
                DispatchQueue.main.async {
                    dispatchOnMainThread()
                }
            }
        }
    }
}
