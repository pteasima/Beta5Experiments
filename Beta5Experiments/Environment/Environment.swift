import Combine

struct Environment {
  var github: Github = .init()
  var clock: Clock = .init()
}

extension Environment {
  static let live: Environment = .init(
    github: .live,
    clock: .live
  )
}

