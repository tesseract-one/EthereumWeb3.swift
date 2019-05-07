//
//  EthereumTypedData.swift
//  Web3
//
//  Created by Yehor Popovych on 3/19/19.
//

import Foundation
import Ethereum

public struct SignTypedDataCallParams: Codable, Equatable, Hashable {
    
    public let account: Address
    public let data: TypedData
    public let password: String?
    
    public init(account: Address, data: TypedData, password: String? = nil) {
        self.account = account
        self.data = data
        self.password = password
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let account = try container.decode(Address.self)
        let data = try container.decode(TypedData.self)
        let password = try? container.decode(String.self)
        self.init(account: account, data: data, password: password)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(account)
        try container.encode(data)
        if let pwd = password {
            try container.encode(pwd)
        }
    }
}
