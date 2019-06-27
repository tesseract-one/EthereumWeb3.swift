//
//  SendTransaction.swift
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

// eth_sendTransaction
extension EthereumSignProvider {
    func autoNonce(
        _ tx: Transaction,
        cb: @escaping Web3.Completion<Transaction>
    ) {
        guard let from = tx.from else {
            cb(.failure(.requestFailed(SignProviderError.mandatoryFieldMissing("from"))))
            return
        }
        
        guard tx.nonce == nil else {
            cb(.success(tx))
            return
        }
        
        _web3.eth.getTransactionCount(address: from, block: .pending) { res in
            cb(res.map { val in
                var mTx = tx
                mTx.nonce = val
                return mTx
            })
        }
    }
    
    func autoGas(
        _ tx: Transaction,
        cb: @escaping Web3.Completion<Transaction>
    ) {
        if tx.gas != nil && tx.gasPrice != nil {
            cb(.success(tx))
            return
        }
        let gas: Web3.Completion<Quantity> = { res in
            switch res {
            case .failure(let err):
                cb(.failure(err))
                return
            case .success(let gas):
                var mTx = tx
                mTx.gas = Quantity((gas.quantity * 13)/10) // estimateGas can be incorrect sometimes, adding 30% to top
                guard mTx.gasPrice == nil else {
                    cb(.success(mTx))
                    return
                }
                self._web3.eth.gasPrice { res in
                    cb(res.map { val in
                        var mTx2 = mTx
                        mTx2.gasPrice = val
                        return mTx2
                    })
                }
            }
        }
        if let txG = tx.gas {
            gas(.success(txG))
        } else {
            guard let to = tx.to else {
                cb(.failure(.requestFailed(SignProviderError.mandatoryFieldMissing("to"))))
                return
            }
            _web3.eth.estimateGas(
                call: Call(from: tx.from, to: to, gas: tx.gas, gasPrice: tx.gasPrice, value: tx.value, data: tx.data),
                response: gas
            )
        }
    }
    
    func eth_sendTransaction(
        request: RPCRequest<[Transaction]>,
        cb: @escaping Web3.Completion<EthData>
    ) {
        signTransaction(request: request) { res in
            switch res {
            case .failure(let err): cb(.failure(err))
            case .success(let tx): self._web3.eth.sendRawTransaction(transaction: tx, response: cb)
            }
        }
    }
    
    func signTransaction(
        request: RPCRequest<[Transaction]>,
        cb: @escaping Web3.Completion<SignedTransaction>
    ) {
        let signTx = { (tx: Transaction, nId: UInt64, cId: UInt64) -> Void in
            self.sign.eth_signTx(tx: tx, networkId: nId, chainId: cId) { result in
                let signedTx = result
                    .tryMap { signature in
                        try SignedTransaction(
                            tx: tx, signature: signature, chainId: BigUInt(cId)
                        )
                    }
                    .mapError{ProviderError.requestFailed($0)}
                cb(signedTx)
            }
        }
        
        let ids = { (web3Tx: Transaction) -> Void in
            self.networkAndChainId { res in
                switch res {
                case .failure(let err): cb(.failure(err))
                case .success(let val): signTx(web3Tx, val.nId, val.cId)
                }
            }
        }
        
        autoNonce(request.params[0]) { result in
            switch result {
            case .failure(let err): cb(.failure(err))
            case .success(let nTx):
                self.autoGas(nTx) { result in
                    switch result {
                    case .failure(let err): cb(.failure(err))
                    case .success(let gTx): ids(gTx)
                    }
                }
            }
        }
    }
}
