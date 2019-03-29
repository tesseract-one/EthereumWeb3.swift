//
//  Transaction+Web3.swift
//  EthereumWeb3
//
//  Created by Yehor Popovych on 3/14/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BigInt
import EthereumBase
import Web3

public extension Transaction {
    var web3: EthereumTransaction {
        return EthereumTransaction(
            nonce: EthereumQuantity(quantity: nonce),
            gasPrice: EthereumQuantity(quantity: gasPrice),
            gas: EthereumQuantity(quantity: gas),
            from: from.web3,
            to: to?.web3,
            value: EthereumQuantity(quantity: value),
            data: EthereumData(data.bytes)
        )
    }
}


public extension EthereumTransaction {
    func tes() throws -> Transaction {
        guard let nonce = nonce, let gas = gas, let gasPrice = gasPrice, let from = from else {
            throw EthereumSignedTransaction.Error.transactionInvalid
        }
        let value = self.value ?? EthereumQuantity(integerLiteral: 0)
        return Transaction(
            nonce: nonce.quantity,
            gasPrice: gasPrice.quantity,
            gas: gas.quantity,
            from: from.tes,
            to: to?.tes,
            value: value.quantity,
            data: Data(data.bytes)
        )
    }
}

public extension EthereumSignedTransaction {
    init(tx: Transaction, signature: Data, chainId: BigUInt) throws {
        guard signature.count == 65 else {
            throw EthereumSignedTransaction.Error.signatureMalformed
        }
        var v = BigUInt(signature[64])
        if chainId > 0 {
            v += chainId * BigUInt(2) + BigUInt(8)
        }
        self.init(
            nonce: EthereumQuantity(quantity: tx.nonce),
            gasPrice: EthereumQuantity(quantity: tx.gasPrice),
            gasLimit: EthereumQuantity(quantity: tx.gas),
            to: tx.to?.web3,
            value: EthereumQuantity(quantity: tx.value),
            data: EthereumData(tx.data.bytes),
            v: EthereumQuantity(quantity: v),
            r: EthereumQuantity.bytes(signature[0..<32].bytes),
            s: EthereumQuantity.bytes(signature[32..<64].bytes),
            chainId: EthereumQuantity(quantity: chainId)
        )
    }
}

public extension Address {
    var web3: EthereumAddress {
        return try! EthereumAddress(rawAddress: rawValue.bytes)
    }
}

public extension EthereumAddress {
    var tes: Address {
        return try! Address(rawAddress: Data(rawAddress))
    }
}
