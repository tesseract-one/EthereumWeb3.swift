//
//  Result+Extensions.swift
//  EthereumWeb3-iOS
//
//  Created by Yehor Popovych on 5/8/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation

extension Swift.Result {
    func tryMap<T>(mapper: @escaping (Success) throws -> T) -> Swift.Result<T, Swift.Error> {
        switch self {
        case .failure(let err): return .failure(err)
        case .success(let val):
            do {
                return .success(try mapper(val))
            } catch let err {
                return .failure(err)
            }
        }
    }
}

extension Swift.Result where Failure == ProviderError {
    func asyncMap<T: Codable>(_ callback: @escaping Web3.Completion<T>,
                              mapper: @escaping (Success, @escaping (Swift.Result<T, Failure>) -> Void) -> Void) {
        switch self {
        case .failure(let err): callback(.failure(err))
        case .success(let val):
            mapper(val) {
                callback($0)
            }
        }
    }
}
