//
//  EthereumLogsFilter.swift
//  Web3
//
//  Created by Yehor Popovych on 3/16/19.
//

import Foundation
import Ethereum

// Thread unsafe
public struct LogsFilter: LogsFilterProtocol {
    
    private var changes: Array<LogObject>
    
    public private(set) var lastFetched: Date
    
    public let fromBlock: QuantityTag?
    public let toBlock: QuantityTag?
    public let topics: Array<Topic>
    public let address: Address?
    
    public init(
        fromBlock: QuantityTag? = nil,
        toBlock: QuantityTag? = nil,
        address: Address? = nil,
        topics: [Topic] = []
    ) {
        self.lastFetched = Date(timeIntervalSinceNow: -1.0)
        self.changes = []
        self.topics = topics
        self.address = address
        self.fromBlock = fromBlock
        self.toBlock = toBlock
    }
    
    public mutating func getFilterChanges() -> [LogObject] {
        self.lastFetched = Date(timeIntervalSinceNow: 0.0)
        let changes = self.changes
        self.changes.removeAll()
        return changes
    }
    
    public mutating func apply(block: BlockObject, logs: Array<LogObject>) {
        if let from = self.fromBlock, case .block(let fromId) = from.tagType, fromId > block.number!.quantity {
            return
        }
        let topics = self.topics.enumerated()
        let filtered = logs.filter { obj in
            (self.address == nil || self.address == obj.address) && topics.reduce(true) { (prev, data) in
                let (index, elem) = data
                return prev && self.checkTopic(log: obj, index: index, topic: elem)
            }
        }
        self.changes.append(contentsOf: filtered)
    }
    
    private func checkTopic(log: LogObject, index: Int, topic: Topic) -> Bool {
        switch topic {
        case .any:
            return log.topics.count >= index
        case .exact(let data):
            return log.topics.count >= index && log.topics[index] == data
        case .or(let topics):
            return topics.enumerated().reduce(false) { (prev, data) in
                let (index, element) = data
                return prev || self.checkTopic(log: log, index: index, topic: element)
            }
        }
    }
}
