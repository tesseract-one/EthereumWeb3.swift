//
//  SignData.swift
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

// personal_sign, eth_sign
extension EthereumSignProvider {
    private func sign_data(id: Int, account: EthereumAddress, data: EthereumData, cb: @escaping Web3ResponseCompletion<EthereumData>) {
        networkId { res in
            res.asyncMap(id: id, cb) { networkId, response in
                self.sign.eth_signData(
                    account: account.tes,
                    data: Data(data.bytes),
                    networkId: networkId
                ) {
                    response($0.map{EthereumData(raw: $0.bytes)}.mapError{$0})
                }
            }
        }
    }
    
    func personal_sign(req: RPCRequest<EthereumValue>, response: @escaping Web3ResponseCompletion<EthereumData>) {
        guard let params = req.params.array else {
            response(Web3Response(id: req.id, error: SignProviderError.mandatoryFieldMissing("array")))
            return
        }
        guard params.count > 1 else {
            response(Web3Response(id: req.id, error: SignProviderError.emptyAccount))
            return
        }
        let account: EthereumAddress
        do {
            account = try EthereumAddress(ethereumValue: params[1])
        } catch(let err) {
            response(Web3Response(id: req.id, error: err))
            return
        }
        let data: EthereumData
        do {
            data = try EthereumData(ethereumValue: params[0])
        } catch(let err) {
            response(Web3Response(id: req.id, error: err))
            return
        }
        sign_data(id: req.id, account: account, data: data, cb: response)
    }
    
    func eth_sign(req: RPCRequest<EthereumValue>, response: @escaping Web3ResponseCompletion<EthereumData>) {
        guard let params = req.params.array else {
            response(Web3Response(id: req.id, error: SignProviderError.mandatoryFieldMissing("array")))
            return
        }
        let account: EthereumAddress
        do {
            account = try EthereumAddress(ethereumValue: params[0])
        } catch(let err) {
            response(Web3Response(id: req.id, error: err))
            return
        }
        let data: EthereumData
        do {
            data = try EthereumData(ethereumValue: params[1])
        } catch(let err) {
            response(Web3Response(id: req.id, error: err))
            return
        }
        sign_data(id: req.id, account: account, data: data, cb: response)
    }
}
