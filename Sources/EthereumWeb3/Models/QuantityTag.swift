//
//  EthereumQuantityTag.swift
//  Web3
//
//  Created by Koray Koska on 10.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import CryptoSwift
import Ethereum

public struct QuantityTag {

    public enum _Type {
        case block(BigUInt)
        case latest
        case earliest
        case pending
    }

    public let tagType: _Type

    public init(type: _Type) {
        self.tagType = type
    }
}

public extension QuantityTag {

    static var latest: QuantityTag {
        return self.init(type: .latest)
    }

    static var earliest: QuantityTag {
        return self.init(type: .earliest)
    }

    static var pending: QuantityTag {
        return self.init(type: .pending)
    }

    static func block(_ bigUInt: BigUInt) -> QuantityTag {
        return self.init(type: .block(bigUInt))
    }
}

extension QuantityTag: ValueConvertible {

    public static func string(_ string: String) throws -> QuantityTag {
        return try self.init(ethereumValue: .string(string))
    }

    public init(ethereumValue: Value) throws {
        guard let str = ethereumValue.string else {
            throw ValueInitializableError.notInitializable
        }

        if str == "latest" {
            tagType = .latest
        } else if str == "earliest" {
            tagType = .earliest
        } else if str == "pending" {
            tagType = .pending
        } else {
            guard let hex = try? Quantity(hex: str) else {
                throw ValueInitializableError.notInitializable
            }
            tagType = .block(hex.quantity)
        }
    }

    public func ethereumValue() -> Value {
        switch tagType {
        case .latest:
            return "latest"
        case .earliest:
            return "earliest"
        case .pending:
            return "pending"
        case .block(let bigUInt):
            return Value(stringLiteral: Quantity(bigUInt).hex)
        }
    }
}

// MARK: - Equatable

extension QuantityTag._Type: Equatable {

    public static func ==(lhs: QuantityTag._Type, rhs: QuantityTag._Type) -> Bool {
        switch lhs {
        case .block(let bigLeft):
            if case .block(let bigRight) = rhs {
                return bigLeft == bigRight
            }
            return false
        case .latest:
            if case .latest = rhs {
                return true
            }
            return false
        case .earliest:
            if case .earliest = rhs {
                return true
            }
            return false
        case .pending:
            if case .pending = rhs {
                return true
            }
            return false
        }
    }
}

extension QuantityTag: Equatable {

    public static func ==(_ lhs: QuantityTag, _ rhs: QuantityTag) -> Bool {
        return lhs.tagType == rhs.tagType
    }
}

// MARK: - Hashable

extension QuantityTag._Type: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .block(let bigInt):
            hasher.combine(bigInt)
        case .latest:
            hasher.combine(0x01)
        case .earliest:
            hasher.combine(0x02)
        case .pending:
            hasher.combine(0x03)
        }
    }
}

extension QuantityTag: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tagType)
    }
}
