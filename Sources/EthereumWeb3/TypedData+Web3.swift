//
//  TypedData+Web3.swift
//  EthereumWeb3
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import EthereumTypes
import Serializable
import Web3

extension EthereumTypedData {
    var tesTypedData: TypedData {
        return TypedData(
            primaryType: primaryType,
            types: types.mapValues{$0.map{$0.tesType}},
            domain: domain.tesDomain,
            message: message
        )
    }
}

extension EthereumTypedData.Domain {
    var tesDomain: TypedData.Domain {
        return TypedData.Domain(
            name: name,
            version: version,
            chainId: chainId,
            verifyingContract: verifyingContract.tes
        )
    }
}

extension EthereumTypedData._Type {
    var tesType: TypedData._Type {
        return TypedData._Type(name: name, type: type)
    }
}

extension JSONValue: SerializableValueEncodable {
    public var serializable: SerializableValue {
        switch self {
        case .null: return .nil
        case .bool(let bool): return .bool(bool)
        case .number(let num): return .float(num)
        case .string(let str): return .string(str)
        case .array(let arr): return .array(arr.map{$0.serializable})
        case .object(let obj): return .object(obj.mapValues{$0.serializable})
        }
    }
}
