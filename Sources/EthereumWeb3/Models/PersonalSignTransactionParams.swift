//
//  EthereumPersonalSignTransactionParams.swift
//  Web3
//
//  Created by Yehor Popovych on 3/15/19.
//

import Foundation
import Ethereum


public struct PersonalSignTransactionParams: Codable, Equatable, Hashable {
    public let transaction: Transaction
    public let password: String
    
    public init(transaction: Transaction, password: String) {
        self.transaction = transaction
        self.password = password
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let tx = try container.decode(Transaction.self)
        let pwd = try container.decode(String.self)
        self.init(transaction: tx, password: pwd)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(transaction)
        try container.encode(password)
    }
}
