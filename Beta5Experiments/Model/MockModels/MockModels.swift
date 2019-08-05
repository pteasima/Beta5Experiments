import Gen

extension Gen where Value == Gist {
  static func gist() -> Gen {
    zip(
    .always("in: 0...1"),
    .always("in: 0...1"),
    .always([])
    ).map(Gist.init(id:description:files:))
  }
}
