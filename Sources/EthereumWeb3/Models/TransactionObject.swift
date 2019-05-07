//
//  EthereumTransactionObject.swift
//  Alamofire
//
//  Created by Koray Koska on 30.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import Ethereum

public struct TransactionObject: Codable, Equatable, Hashable {

    /// 32 Bytes - hash of the transaction.
    public let hash: EthData

    /// The number of transactions made by the sender prior to this one.
    public let nonce: Quantity

    /// 32 Bytes - hash of the block where this transaction was in. null when its pending.
    public let blockHash: EthData?

    /// Block number where this transaction was in. null when its pending.
    public let blockNumber: Quantity?

    /// Integer of the transactions index position in the block. nil when its pending.
    public let transactionIndex: Quantity?

    /// 20 Bytes - address of the sender.
    public let from: Address

    /// 20 Bytes - address of the receiver. nil when its a contract creation transaction.
    public let to: Address?

    /// Value transferred in Wei.
    public let value: Quantity

    /// Gas price provided by the sender in Wei.
    public let gasPrice: Quantity

    /// Gas provided by the sender.
    public let gas: Quantity

    /// The data send along with the transaction.
    public let input: EthData
}
