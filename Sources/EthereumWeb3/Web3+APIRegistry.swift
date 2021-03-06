//
//  Web3.swift
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
import Ethereum

typealias Web3Class = Web3

public extension Web3 {
    
    init(provider: Provider, sign: SignProvider, chainId: UInt64? = nil, rpcIdCounter: AtomicCounter? = nil) {
        let counter = rpcIdCounter ?? AtomicCounter()
        let signProvider = EthereumSignProvider(
            chainId: chainId, counter: counter,
            web3Provider: provider,
            signProvider: sign
        )
        self.init(provider: signProvider, rpcIdCounter: counter)
    }
    
    init(
        rpcURL: String, sign: SignProvider, chainId: UInt64? = nil,
        handleFilters: Bool = true,
        session: URLSession = URLSession(configuration: .default),
        headers: Dictionary<String, String>? = nil
    ) {
        let counter = AtomicCounter()
        let provider: Provider
        if handleFilters {
            provider = HttpProviderFilterHandler(
                HttpProvider(rpcURL: rpcURL, session: session, headers: headers),
                counter: counter
            )
        } else {
            provider = HttpProvider(rpcURL: rpcURL, session: session, headers: headers)
        }
        self.init(provider: provider, sign: sign, chainId: chainId, rpcIdCounter: counter)
    }
}

public extension ModuleAPIRegistry {
    
    func Web3(
        rpcUrl: String, chainId: UInt64? = nil,
        session: URLSession = URLSession(configuration: .default),
        headers: Dictionary<String, String>? = nil
    ) -> Web3 {
        return Web3Class(
            rpcURL: rpcUrl, sign: signProvider,
            chainId: chainId, handleFilters: true,
            session: session, headers: headers
        )
    }
    
    func Web3(
        provider: Provider, chainId: UInt64? = nil,
        rpcIdCounter: AtomicCounter? = nil
    ) -> Web3 {
        return Web3Class(
            provider: provider, sign: signProvider,
            chainId: chainId, rpcIdCounter: rpcIdCounter
        )
    }
}

public extension InstanceAPIRegistry {
    
    func web3(
        rpcUrl: String, chainId: UInt64? = nil,
        session: URLSession = URLSession(configuration: .default),
        headers: Dictionary<String, String>? = nil
    ) -> Web3 {
        return Web3Class(
            rpcURL: rpcUrl, sign: signProvider,
            chainId: chainId, handleFilters: true,
            session: session, headers: headers
        )
    }
    
    func web3(
        provider: Provider, chainId: UInt64? = nil,
        rpcIdCounter: AtomicCounter? = nil
    ) -> Web3 {
        return Web3Class(
            provider: provider, sign: signProvider,
            chainId: chainId, rpcIdCounter: rpcIdCounter
        )
    }
}
