import XCTest

import EthereumWeb3Tests

var tests = [XCTestCaseEntry]()
tests += EthereumWeb3Tests.__allTests()

XCTMain(tests)
