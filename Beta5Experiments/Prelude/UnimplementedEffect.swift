import Combine

func unimplemented<Input, Output>(_ input: Input) -> AnyPublisher<Output, Never> {
  Empty(completeImmediately: true).breakpoint(receiveSubscription: {
    print($0)
    //            #if canImport(XCTest)
    //            XCTAssert(false)
    //            #endif
    return true
  }).eraseToAnyPublisher()
}

