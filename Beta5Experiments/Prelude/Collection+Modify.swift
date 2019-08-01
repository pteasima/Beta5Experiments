import Foundation

extension MutableCollection {
    mutating func modify(_ modifications: (inout Element) -> Void) {
        indices.forEach { idx in
            var element: Element {
                get {
                    self[idx]
                }
                set {
                    self[idx] = newValue
                }
            }
            modifications(&element)
        }
    }
}

extension MutableCollection {
    mutating func modify(where predicate: (Element) -> Bool, _ modifications: (inout Element) -> Void) {
        modify {
            if predicate($0) {
                modifications(&$0)
            }
        }
    }
}
