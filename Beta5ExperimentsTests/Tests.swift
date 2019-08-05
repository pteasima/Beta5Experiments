//
//  Beta5ExperimentsTests.swift
//  Beta5ExperimentsTests
//
//  Created by Petr Šíma on 31/07/2019.
//  Copyright © 2019 Petr Šíma. All rights reserved.
//

import XCTest
@testable import Beta5Experiments
import SwiftUI


class Tests: XCTestCase {

    func testGistDelete() {
        var state = AppState()
      state.reduce(.gist(id: "1", gistAction: .delete))
      print(state)
    }
  func testGistDeleteOnStore() {
    var store = Store<AppState, AppState.Action>.application(environment: Environment(), initialState: AppState(
      gists: [
        GistState(gist: Gist(
          id: .init(rawValue: "1"),
          description: "first",
          files: []
        )),
        GistState(gist: Gist(
          id: .init(rawValue: "2"),
          description: "second",
          files: []
        )),
      ]
    ))
//    let vc = UIHostingController(rootView: NavigationView {
//      GistList(store: store)
//    })
//    UIApplication.shared.keyWindow?.rootViewController = vc
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    store.dispatch(.gist(id: "1", gistAction: .delete))
      print("state", store.stateObject.state)
//    }


//    self.expectation(description: "hold up")
//    waitForExpectations(timeout: 1000, handler: nil)
  }
}
