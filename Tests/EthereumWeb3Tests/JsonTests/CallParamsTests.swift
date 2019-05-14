//
//  EthereumCallParamsTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 11.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif


class CallParamsTests: XCTestCase {
    
    var encoder: JSONEncoder = JSONEncoder()
    var decoder: JSONDecoder = JSONDecoder()
    
    func assignEncoderAndDecoder() {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
    
    func testEncoding() {
        self.assignEncoderAndDecoder()
        
        let e = try? CallParams(
            from: Address(hex: "0x52bc44d5378309EE2abF1539BF71dE1b7d7bE3b5", eip55: true),
            to: Address(hex: "0x829BD824B016326A401d083B33D092293333A830", eip55: true),
            gas: 21000,
            gasPrice: Quantity(21 * BigUInt(10).power(9)),
            value: 10,
            data: EthData([0x00, 0xff]),
            block: .latest
        )
        XCTAssertNotNil(e, "should not be nil")
        guard let call = e else { return }
        
        let newCall = try? self.decoder.decode(CallParams.self, from: self.encoder.encode(call))
        XCTAssertNotNil(newCall, "should not be nil")
        
        XCTAssertEqual(newCall?.from?.hex(eip55: true), "0x52bc44d5378309EE2abF1539BF71dE1b7d7bE3b5", "should be equal")
        XCTAssertEqual(newCall?.to.hex(eip55: true), "0x829BD824B016326A401d083B33D092293333A830", "should be equal")
        XCTAssertEqual(newCall?.gas?.quantity, 21000, "should be equal")
        XCTAssertEqual(newCall?.gasPrice?.quantity, 21 * BigUInt(10).power(9), "should be equal")
        XCTAssertEqual(newCall?.value?.quantity, 10, "should be equal")
        XCTAssertEqual(newCall?.data?.data.bytes, [0x00, 0xff], "should be equal")
        XCTAssertEqual(newCall?.block.tagType, .latest, "should be equal")
        
        XCTAssertEqual(call == newCall, true, "should be equatable")
        
        XCTAssertEqual(call.hashValue, newCall?.hashValue, "should produce correct hashValues")
    }
    
    func testDecoding() {
        self.assignEncoderAndDecoder()
        
        let str = "[{\"value\":\"0xa\",\"to\":\"0x829bd824b016326a401d083b33d092293333a830\",\"gas\":\"0x5208\",\"data\":\"0x00ff\",\"gasPrice\":\"0x4e3b29200\",\"from\":\"0x52bc44d5378309ee2abf1539bf71de1b7d7be3b5\"},\"latest\"]"
        let e = try? self.decoder.decode(CallParams.self, from: Data(str.bytes))
        XCTAssertNotNil(e, "should not be nil")
        
        XCTAssertEqual(e?.block.tagType, QuantityTag._Type.latest, "should be equal")
        XCTAssertEqual(e?.from?.hex(eip55: true), "0x52bc44d5378309EE2abF1539BF71dE1b7d7bE3b5", "should be equal")
        XCTAssertEqual(e?.to.hex(eip55: true), "0x829BD824B016326A401d083B33D092293333A830", "should be equal")
        XCTAssertEqual(e?.gas?.quantity, BigUInt(21000), "should be equal")
        XCTAssertEqual(e?.gasPrice?.quantity, 21 * BigUInt(10).power(9), "should be equal")
        XCTAssertEqual(e?.value?.quantity, BigUInt(10), "should be equal")
        XCTAssertEqual(e?.data?.data.bytes, [0x00, 0xff], "should be equal")
    }
}
