import Foundation

struct AppState {
    var dateText: String = ""
}
extension AppState: Application {
    enum Action {
        case none
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
        print("reduce", action)
        switch action {
        case .none:
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
