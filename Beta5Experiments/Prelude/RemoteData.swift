//http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html
enum RemoteData<Value, Error: Swift.Error> {
    case notRequested
    case loading
    case result(Result<Value, Error>)

    var notRequested: Void? {
        guard case .notRequested = self else { return nil }
        return ()
    }

    var loading: Void? {
        guard case .loading = self else { return nil }
        return ()
    }

    var result: Result<Value, Error>? {
        get {
            guard case let .result(value) = self else { return nil }
            return value
        }
        set {
            guard case .result = self, let newValue = newValue else { return }
            self = .result(newValue)
        }
    }
}

