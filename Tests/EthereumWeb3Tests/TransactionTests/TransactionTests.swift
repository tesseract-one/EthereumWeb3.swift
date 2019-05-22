//
//  TransactionTests.swift
//  EthereumWeb3
//
//  Created by Yura Kulynych on 5/21/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif


class TransactionTests: XCTestCase {
    
    private let web3: Web3 = {
        let infuraUrl = "https://mainnet.infura.io/rFWTF4C1mwjexZVw0LoU"
        return Web3(rpcURL: infuraUrl)
    }()
}
