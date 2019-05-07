//
//  Web3Provider.swift
//  Web3
//
//  Created by Koray Koska on 30.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import Ethereum

public protocol DataProvider {
    func send(data: Data, response: @escaping(Swift.Result<Data, Error>) -> Void)
}

public enum ProviderError: Swift.Error {
    case emptyResponse
    case requestFailed(Swift.Error?)
    case connectionFailed(Swift.Error?)
    case serverError(Swift.Error?)
    case signProviderError(SignProviderError)
    case rpcError(Swift.Error)
    case decodingError(Swift.Error?)
}

public protocol Provider {
    typealias Response<R: Codable> = Swift.Result<R, ProviderError>
    typealias Completion<R: Codable> = (Response<R>) -> Void
    
    var dataProvider: DataProvider { get }
    
    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>)
}

extension Provider where Self: DataProvider {
    public var dataProvider: DataProvider {
        return self
    }
}

public protocol InjectedProvider: Provider {
    var provider: Provider { get }
}

extension InjectedProvider {
    public var dataProvider: DataProvider {
        return provider.dataProvider
    }
}

extension Swift.Result where Failure == ProviderError, Success: Codable {
    public init(rpcResponse: RPCResponse<Success>) {
        if let result = rpcResponse.result {
            self = .success(result)
        } else if let error = rpcResponse.error {
            self = .failure(ProviderError.rpcError(error))
        } else {
            self = .failure(ProviderError.emptyResponse)
        }
    }
}
