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
    
    private let rpcId = 1
    private let jsonrpc = Web3.jsonrpc
    
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
    }
    
    func send(data: Data, response: @escaping (Swift.Result<Data, Error>) -> Void) {}
    
    func getExpectedRequest(_ method: String, _ params: SerializableValue) -> SerializableValue {
        return ["id": rpcId, "jsonrpc": jsonrpc, "method": method, "params": params]
    }
    
    func getJsonResponse(_ res: String, _ withQuotes: Bool = true, params: Array<Any> = []) -> String {
        return
            """
            {
                "id": \(rpcId),
                "jsonrpc": "\(jsonrpc)",
                "result": \(withQuotes ? "\"\(res)\"" : res),
                "params": \(params)
            }
            """
    }

    func getResult<Params, Result>(req: RPCRequest<Params>, expectedReq: SerializableValue, jsonResponse: String) -> Swift.Result<Result, ProviderError> where Result: Codable {
        do {
            let encodedReq = try encoder.encode(req)
            let decodedReq = try decoder.decode(SerializableValue.self, from: encodedReq)
            let responseData = jsonResponse.data(using: .utf8)!
            let decodedResponse = try decoder.decode(RPCResponse<Result>.self, from: responseData)
            return decodedReq == expectedReq
                ? Swift.Result(rpcResponse: decodedResponse)
                : .failure(.decodingError(NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Request is not the same as expected"]) as Error))
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>) {
        queue.async {
            let res: Swift.Result<Result, ProviderError>
            let expectedReq: SerializableValue
            let jsonResponse: String
            
            switch request.method {
            case "web3_clientVersion":
                expectedReq = self.getExpectedRequest("web3_clientVersion", SerializableValue([]))
                jsonResponse = self.getJsonResponse("Geth/v1.8.22-omnibus-260f7fbd/linux-amd64/go1.11.1")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "net_version":
                expectedReq = self.getExpectedRequest("net_version", SerializableValue([]))
                jsonResponse = self.getJsonResponse("1")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "net_peerCount":
                expectedReq = self.getExpectedRequest("net_peerCount", SerializableValue([]))
                // result: Ethereum.Quantity(quantity: 100)
                jsonResponse = self.getJsonResponse("0x64")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_protocolVersion":
                expectedReq = self.getExpectedRequest("eth_protocolVersion", SerializableValue([]))
                jsonResponse = self.getJsonResponse("0x3f")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_syncing":
                expectedReq = self.getExpectedRequest("eth_syncing", SerializableValue([]))
                // result: EthereumWeb3.SyncStatusObject(syncing: false, startingBlock: nil, currentBlock: nil, highestBlock: nil))
                jsonResponse = self.getJsonResponse("false", false)
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_mining":
                expectedReq = self.getExpectedRequest("eth_mining", SerializableValue([]))
                jsonResponse = self.getJsonResponse("false", false)
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_hashrate":
                expectedReq = self.getExpectedRequest("eth_hashrate", SerializableValue([]))
                // result: Ethereum.Quantity(quantity: 0)
                jsonResponse = self.getJsonResponse("0x0")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_gasPrice":
                expectedReq = self.getExpectedRequest("eth_gasPrice", SerializableValue([]))
                // result: Ethereum.Quantity(quantity: 3500000000)
                jsonResponse = self.getJsonResponse("0xd09dc300")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_accounts":
                expectedReq = self.getExpectedRequest("eth_accounts", SerializableValue([]))
                jsonResponse = self.getJsonResponse("[]", false)
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_blockNumber":
                expectedReq = self.getExpectedRequest("eth_blockNumber", SerializableValue([]))
                // result: Ethereum.Quantity(quantity: 7783959)
                jsonResponse = self.getJsonResponse("0x76c617")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getBalance":
                expectedReq = self.getExpectedRequest("eth_getBalance", SerializableValue(["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x3d0900"]))
                // result: Ethereum.Quantity(quantity: 565484140685075537013)
                jsonResponse = self.getJsonResponse("0x1ea7ab3de3c2f1dc75")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getStorageAt":
                expectedReq = self.getExpectedRequest("eth_getStorageAt", SerializableValue(["0x06012c8cf97bead5deae237070f9587f8e7a266d", "0x0", "latest"]))
                // result: Ethereum.EthData(hex: 0x000000000000000000000000af1e54b359b0897133f437fc961dd16f20c045e1)
                jsonResponse = self.getJsonResponse("0x000000000000000000000000af1e54b359b0897133f437fc961dd16f20c045e1")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getTransactionCount":
                expectedReq = self.getExpectedRequest("eth_getTransactionCount", SerializableValue(["0x464b0b37db1ee1b5fbe27300acfbf172fd5e4f53", "0x3d0900"]))
                // result: Ethereum.Quantity(quantity: 216)
                jsonResponse = self.getJsonResponse("0xd8")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getBlockTransactionCountByHash":
                 expectedReq = self.getExpectedRequest("eth_getBlockTransactionCountByHash", SerializableValue(["0x596f2d863a893392c55b72b5ba29e9ba67bdaa13c31765f9119e850a62565960"]))
                // result: Ethereum.Quantity(quantity: 170)
                jsonResponse = self.getJsonResponse("0xaa")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getBlockTransactionCountByNumber":
                expectedReq = self.getExpectedRequest("eth_getBlockTransactionCountByNumber", SerializableValue(["0x525b8d"]))
                // result: Ethereum.Quantity(quantity: 88)
                jsonResponse = self.getJsonResponse("0x58")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getUncleCountByBlockHash":
                expectedReq = self.getExpectedRequest("eth_getUncleCountByBlockHash", SerializableValue(["0xd8cdd624c5b4c5323f0cb8536ca31de046e3e4a798a07337489bab1bb3d822f0"]))
                // result: Ethereum.Quantity(quantity: 1)
                jsonResponse = self.getJsonResponse("0x1")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getUncleCountByBlockNumber":
                expectedReq = self.getExpectedRequest("eth_getUncleCountByBlockNumber", SerializableValue(["0x525bb5"]))
                // result: Ethereum.Quantity(quantity: 1)
                jsonResponse = self.getJsonResponse("0x1")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_getCode":
                expectedReq = self.getExpectedRequest("eth_getCode", SerializableValue(["0x2e704bf506b96adac7ad1df0db461344146a4657", "0x525c15"]))
                // result: Ethereum.EthData(hex: ...)
                jsonResponse = self.getJsonResponse("0x60606040526004361061006c5763ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663022914a78114610071578063173825d9146100a457806341c0e1b5146100c55780637065cb48146100d8578063aa1e84de146100f7575b600080fd5b341561007c57600080fd5b610090600160a060020a036004351661015a565b604051901515815260200160405180910390f35b34156100af57600080fd5b6100c3600160a060020a036004351661016f565b005b34156100d057600080fd5b6100c36101b7565b34156100e357600080fd5b6100c3600160a060020a03600435166101ea565b341561010257600080fd5b61014860046024813581810190830135806020601f8201819004810201604051908101604052818152929190602084018383808284375094965061023595505050505050565b60405190815260200160405180910390f35b60006020819052908152604090205460ff1681565b600160a060020a03331660009081526020819052604090205460ff16151561019657600080fd5b600160a060020a03166000908152602081905260409020805460ff19169055565b600160a060020a03331660009081526020819052604090205460ff1615156101de57600080fd5b33600160a060020a0316ff5b600160a060020a03331660009081526020819052604090205460ff16151561021157600080fd5b600160a060020a03166000908152602081905260409020805460ff19166001179055565b6000816040518082805190602001908083835b602083106102675780518252601f199092019160209182019101610248565b6001836020036101000a0380198251168184511617909252505050919091019250604091505051809103902090509190505600a165627a7a7230582085affe2ee33a8eb3900e773ef5a0d7f1bc95448e61a845ef36e00e6d6b4872cf0029")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_call":
                expectedReq = self.getExpectedRequest("eth_call", SerializableValue([["data": "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000", "to": "0x2e704bf506b96adac7ad1df0db461344146a4657"], "latest"]))
                // result: Ethereum.EthData(hex: "0x5e2393c41c2785095aa424cf3e033319468b6dcebda65e61606ee2ae2a198a87")
                jsonResponse = self.getJsonResponse("0x5e2393c41c2785095aa424cf3e033319468b6dcebda65e61606ee2ae2a198a87")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            case "eth_estimateGas":
                expectedReq = self.getExpectedRequest("eth_estimateGas", SerializableValue([["to": "0x2e704bf506b96adac7ad1df0db461344146a4657", "data": "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"]]))
                // result: Ethereum.Quantity(quantity: 22748)
                jsonResponse = self.getJsonResponse("0x58dc")
                res = self.getResult(req: request, expectedReq: expectedReq, jsonResponse: jsonResponse)
            default:
                res = .failure(.requestFailed(NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Can't test request of this method"]) as Error))
            }

            response(res)
        }
    }
}
