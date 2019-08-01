import Foundation

struct AppState {
    var isToggleOn: Bool = true
    var dateText: String = ""
}
extension AppState: Application {
    enum Action {
        case none
        case toggle(Bool)
        case onTick(Date)
        
        var none: Void? {
            get {
                guard case .none = self else { return nil }
                return ()
            }
            set {
                guard let _ = newValue else { return }
                self = .none
            }
        }
        
        var toggle: Bool? {
            get {
                guard case let .toggle(value) = self else { return nil }
                return value
            }
            set {
                guard let newValue = newValue else { return }
                self = .toggle(newValue)
            }
        }
        
        var onTick: Date? {
            get {
                guard case let .onTick(value) = self else { return nil }
                return value
            }
            set {
                guard let newValue = newValue else { return }
                self = .onTick(newValue)
            }
        }
    }
    
    mutating func reduce(_ action: AppState.Action) -> [Effect<AppState.Action, Unit>] {
        switch action {
        case .none:
            return []
        case let .toggle(to):
            isToggleOn = to
            return []
        case let .onTick(date):
            dateText = String(describing: date)
            return []
        }
    }
}
extension AppState.Action: EmptyInitializable {
    init() { self = .none }
}
