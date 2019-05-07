//
//  EthereumBlockFilter.swift
//  Web3
//
//  Created by Yehor Popovych on 3/16/19.
//

import Foundation
import Ethereum

// Thread unsafe
public struct BlockFilter: BlockFilterProtocol {
    public private(set) var lastFetched: Date
    
    private var lastBlock: BlockObject?
    private var changes: Array<EthData>
    
    public init() {
        self.lastFetched = Date(timeIntervalSinceNow: -1.0)
        self.lastBlock = nil
        self.changes = []
    }
    
    public mutating func getFilterChanges() -> [EthData] {
        self.lastFetched = Date(timeIntervalSinceNow: 0)
        let changes = self.changes
        self.changes.removeAll()
        return changes
    }
    
    public mutating func apply(block: BlockObject) {
        guard let blockNum = block.number, let hash = block.hash else { return }
        guard lastBlock == nil || lastBlock!.number!.quantity < blockNum.quantity else { return }
        self.lastBlock = block
        self.changes.append(hash)
    }
}
