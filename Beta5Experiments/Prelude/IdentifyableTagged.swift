import Tagged

extension Tagged: Identifiable where RawValue == String {
    public var id: String {
        rawValue
    }
}
