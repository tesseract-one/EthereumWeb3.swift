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
import Ethereum

// personal_sign, eth_sign
extension EthereumSignProvider {
    private func sign_data(account: Address, data: Data, cb: @escaping Completion<EthData>) {
        networkId { res in
            res.asyncMap(cb) { networkId, response in
                self.sign.eth_signData(
                    account: account,
                    data: data,
                    networkId: networkId
                ) {
                    response($0.map{EthData($0)}.mapError{.signProviderError($0)})
                }
            }
        }
    }
    
    func personal_sign(req: RPCRequest<Value>, response: @escaping Completion<EthData>) {
        guard let params = req.params.array else {
            response(.failure(.signProviderError(.mandatoryFieldMissing("array"))))
            return
        }
        guard params.count > 1 else {
            response(.failure(.signProviderError(.emptyAccount)))
            return
        }
        let account: Address
        do {
            account = try Address(ethereumValue: params[1])
        } catch(let err) {
            response(.failure(.decodingError(err)))
            return
        }
        let data: EthData
        do {
            data = try EthData(ethereumValue: params[0])
        } catch(let err) {
            response(.failure(.decodingError(err)))
            return
        }
        sign_data(account: account, data: data.data, cb: response)
    }
    
    func eth_sign(req: RPCRequest<Value>, response: @escaping Completion<EthData>) {
        guard let params = req.params.array else {
            response(.failure(.signProviderError(.mandatoryFieldMissing("array"))))
            return
        }
        let account: Address
        do {
            account = try Address(ethereumValue: params[0])
        } catch(let err) {
            response(.failure(.decodingError(err)))
            return
        }
        let data: EthData
        do {
            data = try EthData(ethereumValue: params[1])
        } catch(let err) {
            response(.failure(.decodingError(err)))
            return
        }
        sign_data(account: account, data: data.data, cb: response)
    }
}
