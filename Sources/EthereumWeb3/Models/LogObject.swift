//
//  EthereumLogObject.swift
//  Web3
//
//  Created by Koray Koska on 31.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import Ethereum

public struct LogObject: Codable, Equatable, Hashable {

    /// true when the log was removed, due to a chain reorganization. false if its a valid log.
    public let removed: Bool?

    /// Integer of the log index position in the block. nil when its pending log.
    public let logIndex: Quantity?

    /// Integer of the transactions index position log was created from. nil when its pending log.
    public let transactionIndex: Quantity?

    /// 32 Bytes - hash of the transactions this log was created from. nil when its pending log.
    public let transactionHash: EthData?

    /// 32 Bytes - hash of the block where this log was in. nil when its pending. nil when its pending log.
    public let blockHash: EthData?

    /// The block number where this log was in. nil when its pending. nil when its pending log.
    public let blockNumber: Quantity?

    /// 20 Bytes - address from which this log originated.
    public let address: Address

    /// Contains one or more 32 Bytes non-indexed arguments of the log.
    public let data: EthData

    /**
     * Array of 0 to 4 32 Bytes DATA of indexed log arguments.
     *
     * In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256))
     * except you declared the event with the anonymous specifier.)
     */
    public let topics: [EthData]
}
