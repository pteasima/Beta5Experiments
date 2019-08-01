import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Result {
    var success: Success? {
        guard case let .success(success) = self else { return nil }
        return success
    }
    var failure: Failure? {
        guard case let .failure(failure) = self else { return nil }
        return failure
    }
}
