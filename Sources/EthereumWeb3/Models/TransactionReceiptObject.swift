//
//  EthereumTransactionReceiptObject.swift
//  Web3
//
//  Created by Koray Koska on 31.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import Ethereum

public struct TransactionReceiptObject: Codable, Equatable, Hashable {

    /// 32 Bytes - hash of the transaction.
    public let transactionHash: EthData

    /// Integer of the transactions index position in the block.
    public let transactionIndex: Quantity
    
    /// 32 Bytes - hash of the block where this transaction was in.
    public let blockHash: EthData

    /// Block number where this transaction was in.
    public let blockNumber: Quantity

    /// The total amount of gas used when this transaction was executed in the block.
    public let cumulativeGasUsed: Quantity

    /// The amount of gas used by this specific transaction alone.
    public let gasUsed: Quantity

    /// 20 Bytes - The contract address created, if the transaction was a contract creation, otherwise nil.
    public let contractAddress: EthData?

    /// Array of log objects, which this transaction generated.
    public let logs: [LogObject]

    /// 256 Bytes - Bloom filter for light clients to quickly retrieve related logs.
    public let logsBloom: EthData

    /// 32 bytes of post-transaction stateroot (pre Byzantium)
    public let root: EthData?

    /// Either 1 (success) or 0 (failure)
    public let status: Quantity?
}
