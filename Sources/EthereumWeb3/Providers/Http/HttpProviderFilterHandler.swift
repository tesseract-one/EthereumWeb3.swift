//
//  Web3HttpProviderFilterHandler.swift
//  Web3
//
//  Created by Yehor Popovych on 3/15/19.
//

import Foundation
import Ethereum

public struct HttpProviderFilterHandler: InjectedProvider {
    private let _counter: AtomicCounter
    private let _filterEngine: FilterEngine
    
    public let provider: Provider
    
    public init(_ web3Provider: Provider, counter: AtomicCounter) {
        provider = web3Provider
        _counter = counter
        _filterEngine = FilterEngine(provider: web3Provider, counter: counter)
    }
    
    public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3.Completion<Result>) {
        switch request.method {
        case "eth_newFilter":
            let req = request as! RPCRequest<[NewFilterParams]>
            guard req.params.count > 0 else {
                response(.failure(.requestFailed(nil)))
                return
            }
            let filterId = _filterEngine
                .addLogsFilter(filter: LogsFilter(
                    address: req.params[0].address, topics: req.params[0].topics ?? []
                )
            )
            response(.success(filterId as! Result))
        case "eth_newBlockFilter":
            let filterId = _filterEngine.addBlockFilter(filter: BlockFilter())
            response(.success(filterId as! Result))
        case "eth_newPendingTransactionFilter":
            let filterId = _filterEngine.addPendingBlockFilter(filter: PendingTransactionFilter())
            response(.success(filterId as! Result))
        case "eth_uninstallFilter":
            let params = (request as! RPCRequest<Value>).params.array
            guard params != nil, params!.count > 0, let id = params![0].quantity else {
                response(.failure(.requestFailed(nil)))
                return
            }
            let result = _filterEngine.removeFilter(id: id)
            response(.success(result as! Result))
        case "eth_getFilterChanges":
            let params = (request as! RPCRequest<Value>).params.array
            guard params != nil, params!.count > 0, let id = params![0].quantity else {
                response(.failure(.requestFailed(nil)))
                return
            }
            do {
                let changes = try _filterEngine.getFilterChages(id: id)
                response(.success(changes as! Result))
            } catch(let err) {
                response(.failure(.requestFailed(err)))
            }
        case "eth_getFilterLogs":
            let params = (request as! RPCRequest<Value>).params.array
            guard params != nil, params!.count > 0, let id = params![0].quantity else {
                response(.failure(.requestFailed(nil)))
                return
            }
            _filterEngine.getFilterLogs(id: id) { res in
                response(res.map { $0 as! Result })
            }
        default:
            provider.send(request: request, response: response)
        }
    }
}
