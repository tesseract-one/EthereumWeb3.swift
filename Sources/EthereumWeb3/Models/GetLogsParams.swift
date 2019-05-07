//
//  EthereumGetLogsParams.swift
//  Web3
//
//  Created by Yehor Popovych on 3/15/19.
//

import Foundation
import Ethereum


public struct GetLogsParams: Codable, Hashable, Equatable {
    
    public let fromBlock: QuantityTag?
    
    public let toBlock: QuantityTag?
    
    public let address: Address?
    
    public let topics: [Topic]?
    
    public let blockhash: EthData?
    
    public init(
        fromBlock: QuantityTag? = nil,
        toBlock: QuantityTag? = nil,
        address: Address? = nil,
        topics: [Topic]? = nil,
        blockhash: EthData? = nil
    ) {
        self.fromBlock = fromBlock
        self.toBlock = toBlock
        self.address = address
        self.topics = topics
        self.blockhash = blockhash
    }
}
