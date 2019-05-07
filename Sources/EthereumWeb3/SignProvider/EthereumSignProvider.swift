//
//  EthereumSignProvider.swift
//  EthereumWeb3
//
//  Created by Yehor Popovych on 3/2/19.
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

public class EthereumSignProvider: InjectedProvider {
    let _web3: Web3
    private var _networkId: UInt64?
    private var _chainId: UInt64?
    
    public let sign: SignProvider
    public let provider: Provider
    
    init(chainId: UInt64?, counter: AtomicCounter, web3Provider: Provider, signProvider: SignProvider) {
        provider = web3Provider
        sign = signProvider
        _networkId = nil
        _chainId = chainId
        _web3 = Web3(provider: web3Provider, rpcIdCounter: counter)
        networkId({ _ in }) // Prefetch network and chain id
    }
    
    public func chainId(_ cb: @escaping (Swift.Result<UInt64, ProviderError>) -> Void) {
        if let chainId = _chainId {
            cb(.success(chainId))
            return
        }
        networkId(cb)
    }
    
    public func networkId(_ cb: @escaping (Swift.Result<UInt64, ProviderError>) -> Void) {
        if let networkId = _networkId {
            cb(.success(networkId))
            return
        }
        _web3.net.version() { result in
            cb(
                result.tryMap { ver in
                    guard let id = UInt64(ver, radix: 10) else {
                        throw SignProviderError.nonIntNetworkVersion(ver)
                    }
                    self._networkId = id
                    self._chainId = self._chainId ?? id
                    return id
                }
                .mapError{.requestFailed($0)}
            )
        }
    }
    
    public func networkAndChainId(
        _ cb: @escaping (Swift.Result<(nId: UInt64, cId: UInt64), ProviderError>) -> Void
    ) {
        networkId { res in
            switch res {
            case .failure(let err): cb(.failure(err))
            case .success(let nId):
                self.chainId { res in cb(res.map { (nId: nId, cId: $0) }) }
            }
        }
    }
    
    public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>) {
        switch request.method {
        case "eth_accounts":
            eth_accounts(id: request.id) { response($0 as! Response<Result>) }
        case "personal_sign":
            personal_sign(req: request as! RPCRequest<Value>) { response($0 as! Response<Result>) }
        case "eth_sign":
            eth_sign(req: request as! RPCRequest<Value>) { response($0 as! Response<Result>) }
        case "eth_sendTransaction":
            eth_sendTransaction(request: request as! RPCRequest<[Transaction]>) {
                response($0 as! Response<Result>)
            }
        case "eth_signTypedData", "personal_signTypedData":
            eth_signTypedData(request: request as! RPCRequest<SignTypedDataCallParams>) {
                response($0 as! Response<Result>)
            }
        default:
            provider.send(request: request, response: response)
        }
    }
}
