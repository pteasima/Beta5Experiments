import Combine

extension Store {
  func filterMap<Substate>(initialState: Substate, transform: @escaping (State) -> Substate?) -> Store<Substate, Action> {
   print(self)
    
    return Store<Substate, Action>(initialState: initialState, dispatch: dispatch, willChange: self.stateObject.objectWillChange.map { _ in self.stateObject.state }.compactMap(transform).eraseToAnyPublisher())
  }
}
