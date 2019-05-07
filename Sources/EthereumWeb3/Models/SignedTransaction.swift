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
import Ethereum


public struct SignedTransaction: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// The number of transactions made prior to this one
    public let nonce: Quantity
    
    /// Gas price provided Wei
    public let gasPrice: Quantity
    
    /// Gas limit provided
    public let gasLimit: Quantity
    
    /// Address of the receiver
    public let to: Address?
    
    /// Value to transfer provided in Wei
    public let value: Quantity
    
    /// Input data for this transaction
    public let data: EthData
    
    /// EC signature parameter v
    public let v: Quantity
    
    /// EC signature parameter r
    public let r: Quantity
    
    /// EC recovery ID
    public let s: Quantity
    
    /// EIP 155 chainId. Mainnet: 1
    public let chainId: Quantity
    
    // MARK: - Initialization
    
    /**
     * Initializes a new instance of `EthereumSignedTransaction` with the given values.
     *
     * - parameter nonce: The nonce of this transaction.
     * - parameter gasPrice: The gas price for this transaction in wei.
     * - parameter gasLimit: The gas limit for this transaction.
     * - parameter to: The address of the receiver.
     * - parameter value: The value to be sent by this transaction in wei.
     * - parameter data: Input data for this transaction.
     * - parameter v: EC signature parameter v.
     * - parameter r: EC signature parameter r.
     * - parameter s: EC recovery ID.
     * - parameter chainId: The chainId as described in EIP155. Mainnet: 1.
     *                      If set to 0 and v doesn't contain a chainId,
     *                      old style transactions are assumed.
     */
    public init(
        nonce: Quantity,
        gasPrice: Quantity,
        gasLimit: Quantity,
        to: Address?,
        value: Quantity,
        data: EthData,
        v: Quantity,
        r: Quantity,
        s: Quantity,
        chainId: Quantity
    ) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        self.value = value
        self.data = data
        self.v = v
        self.r = r
        self.s = s
        
        if chainId.quantity == 0 && v.quantity >= 37 {
            if v.quantity % 2 == 0 {
                self.chainId = Quantity((v.quantity - 36) / 2)
            } else {
                self.chainId = Quantity((v.quantity - 35) / 2)
            }
        } else {
            self.chainId = chainId
        }
    }
    
    // MARK: - Errors
    
    public enum Error: Swift.Error {
        case transactionInvalid
        case rlpItemInvalid
        case signatureMalformed
    }
}

extension SignedTransaction: RLPItemConvertible {
    
    public init(rlp: RLPItem) throws {
        guard let array = rlp.array, array.count == 9 else {
            throw Error.rlpItemInvalid
        }
        guard let nonce = array[0].bigUInt, let gasPrice = array[1].bigUInt, let gasLimit = array[2].bigUInt,
            let toBytes = array[3].bytes, let to = try? Address(rawAddress: toBytes),
            let value = array[4].bigUInt, let data = array[5].bytes, let v = array[6].bigUInt,
            let r = array[7].bigUInt, let s = array[8].bigUInt else {
                throw Error.rlpItemInvalid
        }
        
        self.init(
            nonce: Quantity(nonce),
            gasPrice: Quantity(gasPrice),
            gasLimit: Quantity(gasLimit),
            to: to,
            value: Quantity(value),
            data: EthData(data),
            v: Quantity(v),
            r: Quantity(r),
            s: Quantity(s),
            chainId: 0
        )
    }
    
    public func rlp() -> RLPItem {
        return RLPItem(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: data,
            v: v,
            r: r,
            s: s
        )
    }
}

public extension SignedTransaction {
    init(tx: Transaction, signature: Data, chainId: BigUInt) throws {
        guard signature.count == 65 else {
            throw SignedTransaction.Error.signatureMalformed
        }
        guard let nonce = tx.nonce, let gasPrice = tx.gasPrice, let gas = tx.gas else {
            throw SignedTransaction.Error.transactionInvalid
        }
        var v = BigUInt(signature[64])
        if chainId > 0 {
            v += chainId * BigUInt(2) + BigUInt(8)
        }
        self.init(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gas,
            to: tx.to,
            value: tx.value ?? 0,
            data: tx.data,
            v: Quantity(v),
            r: Quantity(data: signature[0..<32]),
            s: Quantity(data: signature[32..<64]),
            chainId: Quantity(chainId)
        )
    }
}
