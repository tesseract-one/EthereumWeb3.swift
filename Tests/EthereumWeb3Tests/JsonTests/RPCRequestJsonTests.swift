//
//  RPCRequestJsonTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 31.12.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif

class RPCRequestJsonTests: XCTestCase {
    
    var encoder: JSONEncoder = JSONEncoder()
    var decoder: JSONDecoder = JSONDecoder()
    
    func testPrimitiveValues() {
        let rawClientVersion = """
            {
                "jsonrpc":"2.0",
                "method":"web3_clientVersion",
                "params":[],
                "id":28
            }
        """.data(using: .utf8)
        XCTAssertNotNil(rawClientVersion, "should not be nil")
        
        let req: RPCRequest! = try? self.decoder.decode(BasicRPCRequest.self, from: rawClientVersion!)
        XCTAssertNotNil(req, "should decode successfully")
        
        XCTAssertEqual(req.jsonrpc, "2.0", "should be jsonrpc version 2.0")
        
        XCTAssertEqual(req.method, "web3_clientVersion", "should be method web3_clientVersion")
        
        XCTAssertNotNil(req.params.array, "should be an array")
        
        XCTAssertEqual(req.params.array?.count, 0, "should have no params")
        
        XCTAssertEqual(req.id, 28, "should have the id 28")
    }
}
