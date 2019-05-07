//
//  EthereumFilter.swift
//  Web3
//
//  Created by Yehor Popovych on 3/16/19.
//

import Foundation
import Ethereum

public protocol BlockFilterProtocol {
    // last get changes date from this event. For auto destroying
    var lastFetched: Date { get }
    
    // Should empty events and update lastUpdated
    mutating func getFilterChanges() -> [EthData]
    
    // New events arrived. Should filter them and add to internal events list if needed
    mutating func apply(block: BlockObject)
}

public protocol LogsFilterProtocol {
    
    // Parameters
    var fromBlock: QuantityTag? { get }
    var toBlock: QuantityTag? { get }
    var address: Address? { get }
    var topics: Array<Topic> { get }
    
    // last get changes date from this event. For auto destroying
    var lastFetched: Date { get }
    
    // Should empty events and update lastUpdated
    mutating func getFilterChanges() -> [LogObject]
    
    // New events arrived. Should filter them and add to internal events list if needed
    mutating func apply(block: BlockObject, logs: Array<LogObject>)
}
