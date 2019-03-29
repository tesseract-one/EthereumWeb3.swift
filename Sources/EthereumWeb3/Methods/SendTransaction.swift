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
import EthereumBase
import Web3

// eth_sendTransaction
extension EthereumSignProvider {
    func autoNonce(
        _ tx: EthereumTransaction,
        cb: @escaping (Swift.Result<EthereumTransaction, Error>) -> Void
    ) {
        guard let from = tx.from else {
            cb(.failure(SignProviderError.mandatoryFieldMissing("from")))
            return
        }
        
        guard tx.nonce == nil else {
            cb(.success(tx))
            return
        }
        
        _web3.eth.getTransactionCount(address: from, block: .pending) { res in
            if let val = res.result {
                var mTx = tx
                mTx.nonce = val
                cb(.success(mTx))
            } else {
                cb(.failure(res.error!))
            }
        }
    }
    
    func autoGas(
        _ tx: EthereumTransaction,
        cb: @escaping (Swift.Result<EthereumTransaction, Error>
    ) -> Void) {
        if tx.gas != nil && tx.gasPrice != nil {
            cb(.success(tx))
            return
        }
        let gas = { (res: Web3Response<EthereumQuantity>) -> Void in
            guard res.error == nil else {
                cb(.failure(res.error!))
                return
            }
            var mTx = tx
            mTx.gas = res.result
            guard mTx.gasPrice == nil else {
                cb(.success(mTx))
                return
            }
            self._web3.eth.gasPrice { res in
                guard res.error == nil else {
                    cb(.failure(res.error!))
                    return
                }
                var mTx2 = mTx
                mTx2.gasPrice = res.result!
                cb(.success(mTx2))
            }
        }
        if let txG = tx.gas {
            gas(Web3Response(id: 0, status: .success(txG)))
        } else {
            guard let to = tx.to else {
                cb(.failure(SignProviderError.mandatoryFieldMissing("to")))
                return
            }
            _web3.eth.estimateGas(
                call: EthereumCall(from: tx.from, to: to, gas: tx.gas, gasPrice: tx.gasPrice, value: tx.value, data: tx.data),
                response: gas
            )
        }
    }
    
    func eth_sendTransaction(
        request: RPCRequest<[EthereumTransaction]>,
        cb: @escaping (Web3Response<EthereumData>) -> Void
    ) {
        signTransaction(request: request) { res in
            switch res {
            case .failure(let err): cb(Web3Response(id: request.id, error: err))
            case .success(let tx): self._web3.eth.sendRawTransaction(transaction: tx, response: cb)
            }
        }
    }
    
    func signTransaction(
        request: RPCRequest<[EthereumTransaction]>,
        cb: @escaping (Swift.Result<EthereumSignedTransaction, Error>) -> Void
    ) {
        let signTx = { (web3Tx: EthereumTransaction, nId: UInt64, cId: UInt64) -> Void in
            let tx: Transaction
            do {
                tx = try web3Tx.tes()
            } catch(let err) {
                cb(.failure(err))
                return
            }
            self.sign.eth_signTx(tx: tx, networkId: nId, chainId: cId) { result in
                let signedTx = result
                    .mapError{$0}
                    .flatMap { signature -> Swift.Result<EthereumSignedTransaction, Error> in
                        do {
                            return .success(try EthereumSignedTransaction(
                                tx: tx, signature: signature, chainId: BigUInt(cId)
                                ))
                        } catch let err {
                            return .failure(err)
                        }
                }
                cb(signedTx)
            }
        }
        
        let ids = { (web3Tx: EthereumTransaction) -> Void in
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
