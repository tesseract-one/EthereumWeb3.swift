//
//  EthereumQuantityTagTests.swift
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


class QuantityTagTests: XCTestCase {
    
    func testInitialization() {
        let t1: QuantityTag = .latest
        XCTAssertEqual(t1.tagType == .latest, true, "should initialize correctly")

        let t2: QuantityTag = .earliest
        XCTAssertEqual(t2.tagType == .earliest, true, "should initialize correctly")

        let t3: QuantityTag = .pending
        XCTAssertEqual(t3.tagType == .pending, true, "should initialize correctly")

        let t4: QuantityTag = .block(100)
        XCTAssertEqual(t4.tagType == .block(100), true, "should initialize correctly")

        let t5: QuantityTag? = try? .string("latest")
        XCTAssertEqual(t5?.tagType == .latest, true, "should initialize correctly")

        let t6: QuantityTag? = try? .string("earliest")
        XCTAssertEqual(t6?.tagType == .earliest, true, "should initialize correctly")

        let t7: QuantityTag? = try? .string("pending")
        XCTAssertEqual(t7?.tagType == .pending, true, "should initialize correctly")

        let t8: QuantityTag? = try? .string("0x12345")
        XCTAssertEqual(t8?.tagType == .block(0x12345), true, "should initialize correctly")
        
        XCTAssertThrowsError(try QuantityTag(ethereumValue: true)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should not initialize")
        }
        XCTAssertThrowsError(try QuantityTag(ethereumValue: ["latest"])) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should not initialize")
        }
        XCTAssertThrowsError(try QuantityTag(ethereumValue: "latee")) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should not initialize")
        }
        XCTAssertThrowsError(try QuantityTag(ethereumValue: "0xxx0")) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should not initialize")
        }
        XCTAssertThrowsError(try QuantityTag(ethereumValue: 12345)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should not initialize")
        }
    }
    
    func testConvertibility() {
        XCTAssertEqual(QuantityTag.latest.ethereumValue().string, "latest", "should convert to ethereum value")
        XCTAssertEqual(QuantityTag.earliest.ethereumValue().string, "earliest", "should convert to ethereum value")
        XCTAssertEqual(QuantityTag.pending.ethereumValue().string, "pending", "should convert to ethereum value")
        XCTAssertEqual(QuantityTag.block(124000).ethereumValue().string, "0x1e460", "should convert to ethereum value")
    }
    
    func testEquitability() {
        XCTAssertEqual(QuantityTag._Type.latest == .latest, true, "should be equal")
        XCTAssertEqual(QuantityTag._Type.earliest == .earliest, true, "should be equal")
        XCTAssertEqual(QuantityTag._Type.pending == .pending, true, "should be equal")
        XCTAssertEqual(QuantityTag._Type.block(1024) == .block(1024), true, "should be equal")
        
        XCTAssertEqual(QuantityTag._Type.latest == .earliest, false, "should not be equal")
        XCTAssertEqual(QuantityTag._Type.earliest == .latest, false, "should not be equal")
        XCTAssertEqual(QuantityTag._Type.pending == .block(128), false, "should not be equal")
        XCTAssertEqual(QuantityTag._Type.block(256) == .pending, false, "should not be equal")
        XCTAssertEqual(QuantityTag._Type.block(256) == .block(255), false, "should not be equal")
    }
    
    func testHashability() {
        let t1: QuantityTag = .latest
        XCTAssertEqual(t1.hashValue, QuantityTag.latest.hashValue, "should produce correct hashValues")
        
        let t2: QuantityTag = .earliest
        XCTAssertEqual(t2.hashValue, QuantityTag.earliest.hashValue, "should produce correct hashValues")
        
        let t3: QuantityTag = .pending
        XCTAssertEqual(t3.hashValue, QuantityTag.pending.hashValue, "should produce correct hashValues")
        
        let t4: QuantityTag = .block(100)
        XCTAssertEqual(t4.hashValue, QuantityTag.block(100).hashValue, "should produce correct hashValues")
    }
}
