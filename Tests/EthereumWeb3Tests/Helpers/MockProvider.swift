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
    
    static func web3(method: String, req: String, res: String) -> Web3 {
        let provider = MockProvider()
        provider.addMethod(method: method, req: req, res: res)
        return Web3(provider: provider)
    }

    var testMethods: [String: (req: String, res: String)]
    
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
    
    init() {
        queue = DispatchQueue.global()
        
        self.testMethods = [:]
    }
    
    func addMethod(method: String, req: String, res: String) {
        testMethods[method] = (req: req, res: res)
    }
    
    func send(data: Data, response: @escaping (Swift.Result<Data, Error>) -> Void) {}

    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>) {
        queue.async {
            do {
                guard let (req, res) = self.testMethods[request.method] else {
                    response(.failure(.requestFailed(nil)))
                    return
                }
                let decodedExpectedReq = try self.decoder.decode(SerializableValue.self, from: req.data(using: .utf8)!)
                let encodedReq = try self.encoder.encode(request)
                let decodedReq = try self.decoder.decode(SerializableValue.self, from: encodedReq)
                guard decodedExpectedReq == decodedReq else {
                    response(.failure(.decodingError(NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Request is not the same as expected"]) as Error)))
                    return
                }
                
                let responseData = res.data(using: .utf8)!
                let decodedResponse = try self.decoder.decode(RPCResponse<Result>.self, from: responseData)
                response(Swift.Result(rpcResponse: decodedResponse))
            } catch {
                response(.failure(.decodingError(error)))
            }
        }
    }
}
