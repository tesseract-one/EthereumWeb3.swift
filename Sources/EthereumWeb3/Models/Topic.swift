//
//  EthereumTopic.swift
//  Web3
//
//  Created by Yehor Popovych on 3/15/19.
//

import Foundation
import Ethereum

public enum Topic: ValueConvertible, Equatable, Hashable {
    case any
    case exact(EthData)
    case or([Topic])
    
    public func ethereumValue() -> Value {
        switch self {
        case .any: return Value(type: .nil)
        case .exact(let data): return data.ethereumValue()
        case .or(let topics): return Value(array: topics)
        }
    }
    
    public init(ethereumValue: Value) throws {
        switch ethereumValue.valueType {
        case .array(let values):
            self = .or(try values.map { try Topic(ethereumValue: $0) })
        case .nil:
            self = .any
        case .string(let hex):
            self = .exact(try EthData(hex: hex))
        default:
            throw ValueInitializableError.notInitializable
        }
    }
}

extension Value {
    public var topic: Topic? {
        return try? Topic(ethereumValue: self)
    }
    
    public var topics: [Topic]? {
        guard let array = self.array else {
            return nil
        }
        return try? array.map { try Topic(ethereumValue: $0) }
    }
}

//extension Topic: Hashable {
//
//    public func hash(into hasher: inout Hasher) {
//        switch self {
//        case .any: hasher.combine(0x00)
//        case .exact(let data): hasher.combine(data)
//        case .or(let topics): hasher.combine(topics)
//        }
//    }
//}
