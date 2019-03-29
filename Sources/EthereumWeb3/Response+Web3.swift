//
//  Response+Web3.swift
//  EthereumWeb3
//
//  Created by Yehor Popovych on 3/29/19.
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
import Web3

typealias Result<Success, Failure: Error> = Swift.Result<Success, Failure>

extension Web3Response {
    init(id: Int, result: Swift.Result<Result, Swift.Error>) {
        switch result {
        case .failure(let err): self.init(id: id, error: err)
        case .success(let val): self.init(id: id, value: val)
        }
    }
}

extension Result {
    func asyncMap<T: Codable>(id: Int,
        _ callback: @escaping (Web3Response<T>) -> Void,
        mapper: @escaping (Success, @escaping (Result<T, Failure>) -> Void) -> Void) {
        switch self {
        case .failure(let err): callback(Web3Response(id: id, error: err))
        case .success(let val):
            mapper(val) {
                callback(Web3Response(id: id, result: $0.mapError{$0}))
            }
        }
    }
}
