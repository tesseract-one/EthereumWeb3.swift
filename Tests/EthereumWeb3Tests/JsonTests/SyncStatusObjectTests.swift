//
//  EthereumSyncStatusObjectTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 13.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif

class SyncStatusObjectTests: XCTestCase {
    
    var encoder: JSONEncoder = JSONEncoder()
    var decoder: JSONDecoder = JSONDecoder()
    
    func testEncoding() {
        let status = SyncStatusObject()
        let e = try? self.encoder.encode([status])
        XCTAssertNotNil(e, "should not be nil")
        guard let encoded = e else { return }
        
        XCTAssertEqual(String(bytes: encoded.bytes, encoding: .utf8), "[false]", "should encode correctly")
        
        let statusAlt = SyncStatusObject(startingBlock: 10000, currentBlock: 20000, highestBlock: 30000)
        let encodedAlt = try? self.decoder.decode(SyncStatusObject.self, from: self.encoder.encode(statusAlt))
        XCTAssertNotNil(encodedAlt, "should not be nil")
        
        XCTAssertEqual(encodedAlt?.startingBlock?.quantity, 10000, "should be equal")
        XCTAssertEqual(encodedAlt?.currentBlock?.quantity, 20000, "should be equal")
        XCTAssertEqual(encodedAlt?.highestBlock?.quantity, 30000, "should be equal")
        XCTAssertEqual(encodedAlt?.syncing, true, "should be equal")
        
        let eA2 = try? self.decoder.decode(SyncStatusObject.self, from: self.encoder.encode(statusAlt))
        XCTAssertEqual(encodedAlt?.hashValue, eA2?.hashValue, "should produce correct hashValues")
    }
    
    func testDecoding() {
        let string = "[false]"
        let decoded = try? self.decoder.decode([SyncStatusObject].self, from: Data(string.bytes))
        XCTAssertNotNil(decoded, "should decode successfully")
        
        XCTAssertEqual(decoded?.count, 1, "should decode successfully")
        XCTAssertEqual(decoded?.first?.syncing, false, "should decode successfully")
        XCTAssertNil(decoded?.first?.startingBlock, "should decode successfully")
        XCTAssertNil(decoded?.first?.currentBlock, "should decode successfully")
        XCTAssertNil(decoded?.first?.highestBlock, "should decode successfully")
        
        let stringAlt = "{\"startingBlock\":\"0x2710\",\"currentBlock\":\"0x4e20\",\"highestBlock\":\"0x7530\"}"
        let decodedAlt = try? self.decoder.decode(SyncStatusObject.self, from: Data(stringAlt.bytes))
        XCTAssertNotNil(decodedAlt, "should decode successfully")
        XCTAssertEqual(decodedAlt?.syncing, true, "should decode successfully")
        XCTAssertEqual(decodedAlt?.startingBlock?.quantity, BigUInt(10000), "should decode successfully")
        XCTAssertEqual(decodedAlt?.currentBlock?.quantity, BigUInt(20000), "should decode successfully")
        XCTAssertEqual(decodedAlt?.highestBlock?.quantity, BigUInt(30000), "should decode successfully")
    }
}
