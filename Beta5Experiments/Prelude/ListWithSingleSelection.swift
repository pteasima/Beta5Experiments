import Foundation

// TODO: give this an initializer and use it
// TODO: write tests, then switch to an unsafe internal representation for better performance
public struct ListWithSingleSelection<Element> {
    
    private var prefix: [Element]
    public private(set) var selectedElement: Element?
    private var suffix: [Element]
    
    public var allElements: [Element] {
        prefix + [selectedElement].compactMap { $0 } + suffix
    }
    public var selectedIndex: Int? {
        selectedElement == nil ? nil : prefix.count
    }
    
    public mutating func selectElement(at index: Int) {
        let allElements = self.allElements
        guard allElements.indices.contains(index) else { return }
        prefix = Array(allElements.prefix(upTo: index))
        selectedElement = allElements[index]
        suffix = Array(allElements.suffix(from: index))
    }
    public mutating func deselect() {
        prefix = allElements
        selectedElement = nil
        suffix = []
    }
}
