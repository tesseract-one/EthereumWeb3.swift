//
//  PromiseKit+Result.swift
//  EthereumWeb3-iOS
//
//  Created by Yehor Popovych on 5/8/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation
import PromiseKit
#if !COCOAPODS
    import EthereumWeb3
#endif

extension Resolver {
    func resolve(_ result: Swift.Result<T, Error>) {
        switch result {
        case .success(let val): fulfill(val)
        case .failure(let err): reject(err)
        }
    }
    
    func resolve(_ result: Swift.Result<T, ProviderError>) {
        switch result {
        case .success(let val): fulfill(val)
        case .failure(let err): reject(err)
        }
    }
}
