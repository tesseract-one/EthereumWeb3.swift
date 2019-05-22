//
//  MockProvider.swift
//  EthereumWeb3
//
//  Created by Yura Kulynych on 5/15/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation
import Dispatch
import Serializable

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif


class MockProvider: DataProvider, Provider {
    
    static func web3(req: String, res: String) -> Web3 {
        return Web3(provider: MockProvider(request: req, response: res))
    }

    let request: String
    let response: String
    
    private let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.dataEncodingStrategy = .base64
        return enc
    }()
    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dataDecodingStrategy = .base64
        return dec
    }()
    
    let queue: DispatchQueue
    
    init(request: String, response: String) {
        queue = DispatchQueue.global()
        
        self.request = request
        self.response = response
    }
    
    func send(data: Data, response: @escaping (Swift.Result<Data, Error>) -> Void) {}

    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>) {
        queue.async {
            do {
                let decodedExpectedReq = try self.decoder.decode(SerializableValue.self, from: self.request.data(using: .utf8)!)
                let encodedReq = try self.encoder.encode(request)
                let decodedReq = try self.decoder.decode(SerializableValue.self, from: encodedReq)
                guard decodedExpectedReq == decodedReq else {
                    response(.failure(.decodingError(NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Request is not the same as expected"]) as Error)))
                    return
                }
                
                let responseData = self.response.data(using: .utf8)!
                let decodedResponse = try self.decoder.decode(RPCResponse<Result>.self, from: responseData)
                response(Swift.Result(rpcResponse: decodedResponse))
            } catch {
                response(.failure(.decodingError(error)))
            }
        }
    }
}
