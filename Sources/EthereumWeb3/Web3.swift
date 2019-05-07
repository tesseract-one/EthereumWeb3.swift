//
//  Web3.swift
//  Web3
//
//  Created by Koray Koska on 30.12.17.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import Ethereum

public struct Web3 {

    public typealias Completion<Result: Codable> = (_ resp: Swift.Result<Result, ProviderError>) -> Void
    public typealias BasicCompletion = Completion<Value>

    public static let jsonrpc = "2.0"

    // MARK: - Properties

    public let properties: Properties

    public struct Properties {
        public let provider: Provider
        private let _rpcId: AtomicCounter
        
        public init(provider: Provider, counter: AtomicCounter) {
            self.provider = provider
            self._rpcId = counter
        }
        
        var rpcId: Int {
            return Int(_rpcId.next())
        }
    }

    // MARK: - Convenient properties

    public var provider: Provider {
        return properties.provider
    }

    public var rpcId: Int {
        return properties.rpcId
    }

    /// The struct holding all `net` requests
    public let net: Net

    /// The struct holding all `eth` requests
    public let eth: Eth
    
    // The struct holding all `personal` requests
    public let personal: Personal

    // MARK: - Initialization

    /**
     * Initializes a new instance of `Web3` with the given custom provider.
     *
     * - parameter provider: The provider which handles all requests and responses.
     */
    public init(provider: Provider, rpcIdCounter: AtomicCounter? = nil) {
        let properties = Properties(provider: provider, counter: rpcIdCounter ?? AtomicCounter())
        self.properties = properties
        self.net = Net(properties: properties)
        self.eth = Eth(properties: properties)
        self.personal = Personal(properties: properties)
    }

    // MARK: - Web3 methods

    /**
     * Returns the current client version.
     *
     * e.g.: "Mist/v0.9.3/darwin/go1.4.1"
     *
     * - parameter response: The response handler. (Returns `String` - The current client version)
     */
    public func clientVersion(response: @escaping Completion<String>) {
        let req = BasicRPCRequest(id: rpcId, jsonrpc: type(of: self).jsonrpc, method: "web3_clientVersion", params: [])

        provider.send(request: req, response: response)
    }

    // MARK: - Net methods
    public struct Net {
        public let properties: Properties

        /**
         * Returns the current network id (chain id).
         *
         * e.g.: "1" - Ethereum Mainnet, "2" - Morden testnet, "3" - Ropsten Testnet
         *
         * - parameter response: The response handler. (Returns `String` - The current network id)
         */
        public func version(response: @escaping Completion<String>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "net_version", params: [])

            properties.provider.send(request: req, response: response)
        }

        /**
         * Returns number of peers currently connected to the client.
         *
         * e.g.: 0x2 - 2
         *
         * - parameter response: The response handler. (Returns `EthereumQuantity` - Integer of the number of connected peers)
         */
        public func peerCount(response: @escaping Completion<Quantity>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "net_peerCount", params: [])

            properties.provider.send(request: req, response: response)
        }
    }

    // MARK: - Eth methods
    public struct Eth {
        public let properties: Properties
        
        // MARK: - Methods

        public func protocolVersion(response: @escaping Completion<String>) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_protocolVersion",
                params: []
            )

            properties.provider.send(request: req, response: response)
        }

        public func syncing(response: @escaping Completion<SyncStatusObject>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_syncing", params: [])

            properties.provider.send(request: req, response: response)
        }

        public func mining(response: @escaping Completion<Bool>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_mining", params: [])

            properties.provider.send(request: req, response: response)
        }

        public func hashrate(response: @escaping Completion<Quantity>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_hashrate", params: [])

            properties.provider.send(request: req, response: response)
        }

        public func gasPrice(response: @escaping Completion<Quantity>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_gasPrice", params: [])

            properties.provider.send(request: req, response: response)
        }

        public func accounts(response: @escaping Completion<[Address]>) {
            let req = BasicRPCRequest(id: properties.rpcId, jsonrpc: Web3.jsonrpc, method: "eth_accounts", params: [])

            properties.provider.send(request: req, response: response)
        }

        public func blockNumber(response: @escaping Completion<Quantity>) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_blockNumber",
                params: []
            )

            properties.provider.send(request: req, response: response)
        }

        public func getBalance(
            address: Address,
            block: QuantityTag = .latest,
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBalance",
                params: [address, block]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getStorageAt(
            address: Address,
            position: Quantity,
            block: QuantityTag = .latest,
            response: @escaping Completion<EthData>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getStorageAt",
                params: [address, position, block]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getTransactionCount(
            address: Address,
            block: QuantityTag = .latest,
            response: @escaping Completion<Quantity>
            ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionCount",
                params: [address, block]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getBlockTransactionCountByHash(
            blockHash: EthData,
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockTransactionCountByHash",
                params: [blockHash]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getBlockTransactionCountByNumber(
            block: QuantityTag,
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockTransactionCountByNumber",
                params: [block]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getUncleCountByBlockHash(
            blockHash: EthData,
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleCountByBlockHash",
                params: [blockHash]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getUncleCountByBlockNumber(
            block: QuantityTag,
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleCountByBlockNumber",
                params: [block]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getCode(
            address: Address,
            block: QuantityTag = .latest,
            response: @escaping Completion<EthData>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getCode",
                params: [address, block]
            )

            properties.provider.send(request: req, response: response)
        }
        
        public func sign(
            account: Address,
            message: EthData,
            response: @escaping Completion<EthData>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_sign",
                params: [account, message]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func signTypedData(
            account: Address,
            data: TypedData,
            response: @escaping Completion<EthData>
        ) {
            let req = RPCRequest<SignTypedDataCallParams>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_signTypedData",
                params: SignTypedDataCallParams(
                    account: account, data: data
                )
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func sendTransaction(
            transaction: Transaction,
            response: @escaping Completion<EthData>
        ) {
            let id = properties.rpcId
            guard transaction.from != nil else {
                response(.failure(.requestFailed(nil)))
                return
            }
            let req = RPCRequest<[Transaction]>(
                id: id,
                jsonrpc: Web3.jsonrpc,
                method: "eth_sendTransaction",
                params: [transaction]
            )
            properties.provider.send(request: req, response: response)
        }

        public func sendRawTransaction(
            transaction: SignedTransaction,
            response: @escaping Completion<EthData>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_sendRawTransaction",
                params: [transaction.rlp()]
            )

            properties.provider.send(request: req, response: response)
        }

        public func call(
            call: Call,
            block: QuantityTag = .latest,
            response: @escaping Completion<EthData>
        ) {
            let req = RPCRequest<CallParams>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_call",
                params: CallParams(call: call, block: block)
            )

            properties.provider.send(request: req, response: response)
        }

        public func estimateGas(call: Call, response: @escaping Completion<Quantity>) {
            let req = RPCRequest<[Call]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_estimateGas",
                params: [call]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getBlockByHash(
            blockHash: EthData,
            fullTransactionObjects: Bool,
            response: @escaping Completion<BlockObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockByHash",
                params: [blockHash, fullTransactionObjects]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getBlockByNumber(
            block: QuantityTag,
            fullTransactionObjects: Bool,
            response: @escaping Completion<BlockObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getBlockByNumber",
                params: [block, fullTransactionObjects]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getTransactionByHash(
            blockHash: EthData,
            response: @escaping Completion<TransactionObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByHash",
                params: [blockHash]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getTransactionByBlockHashAndIndex(
            blockHash: EthData,
            transactionIndex: Quantity,
            response: @escaping Completion<TransactionObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByBlockHashAndIndex",
                params: [blockHash, transactionIndex]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getTransactionByBlockNumberAndIndex(
            block: QuantityTag,
            transactionIndex: Quantity,
            response: @escaping Completion<TransactionObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionByBlockNumberAndIndex",
                params: [block, transactionIndex]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getTransactionReceipt(
            transactionHash: EthData,
            response: @escaping Completion<TransactionReceiptObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getTransactionReceipt",
                params: [transactionHash]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getUncleByBlockHashAndIndex(
            blockHash: EthData,
            uncleIndex: Quantity,
            response: @escaping Completion<BlockObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleByBlockHashAndIndex",
                params: [blockHash, uncleIndex]
            )

            properties.provider.send(request: req, response: response)
        }

        public func getUncleByBlockNumberAndIndex(
            block: QuantityTag,
            uncleIndex: Quantity,
            response: @escaping Completion<BlockObject?>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getUncleByBlockNumberAndIndex",
                params: [block, uncleIndex]
            )

            properties.provider.send(request: req, response: response)
        }
        
        public func newFilter(
            fromBlock: QuantityTag? = nil,
            toBlock: QuantityTag? = nil,
            address: Address? = nil,
            topics: [Topic]? = nil,
            response: @escaping Completion<Quantity>
        ) {
            let req = RPCRequest<[NewFilterParams]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_newFilter",
                params: [NewFilterParams(
                    fromBlock: fromBlock,
                    toBlock: toBlock,
                    address: address,
                    topics: topics
                )]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func newBlockFilter(
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_newBlockFilter",
                params: []
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func newPendingTransactionFilter(
            response: @escaping Completion<Quantity>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_newPendingTransactionFilter",
                params: []
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func uninstallFilter(
            id: Quantity,
            response: @escaping Completion<Bool>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_uninstallFilter",
                params: [id]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func getFilterChanges(
            id: Quantity,
            response: @escaping Completion<FilterChangesObject>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getFilterChanges",
                params: [id]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func getFilterLogs(
            id: Quantity,
            response: @escaping Completion<[LogObject]>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getFilterLogs",
                params: [id]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func getLogs(
            fromBlock: QuantityTag? = nil,
            toBlock: QuantityTag? = nil,
            address: Address? = nil,
            topics: [Topic]? = nil,
            blockhash: EthData? = nil,
            response: @escaping Completion<[LogObject]>
        ) {
            let param = GetLogsParams(
                fromBlock: fromBlock, toBlock: toBlock, address: address,
                topics: topics, blockhash: blockhash
            )
            let req = RPCRequest<[GetLogsParams]>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "eth_getLogs",
                params: [param]
            )
            
            properties.provider.send(request: req, response: response)
        }
    }
    
    // MARK: - Personal methods
    
    public struct Personal {
        public let properties: Properties
        
        public func importRawKey(
            privateKey: EthData,
            password: String,
            response: @escaping Completion<Address>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_importRawKey",
                params: [privateKey, password]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func listAccounts(
            response: @escaping Completion<[Address]>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_listAccounts",
                params: []
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func newAccount(
            password: String,
            response: @escaping Completion<Address>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_newAccount",
                params: [password]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func lockAccount(
            account: Address,
            response: @escaping Completion<Bool>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_lockAccount",
                params: [account]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func unlockAccount(
            account: Address,
            password: String,
            duration: Int? = nil,
            response: @escaping Completion<Bool>
        ) {
            let params: [ValueRepresentable] = duration != nil
                ? [account, password, duration!]
                : [account, password]
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_unlockAccount",
                params: Value(array: params)
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func sendTransaction(
            transaction: Transaction,
            password: String,
            response: @escaping Completion<EthData>
        ) {
            let id = properties.rpcId
            guard transaction.from != nil else {
                response(.failure(.requestFailed(nil)))
                return
            }
            let req = RPCRequest<PersonalSignTransactionParams>(
                id: id,
                jsonrpc: Web3.jsonrpc,
                method: "personal_sendTransaction",
                params: PersonalSignTransactionParams(
                    transaction: transaction, password: password
                )
            )
            properties.provider.send(request: req, response: response)
        }
        
        public func sign(
            message: EthData,
            account: Address,
            password: String,
            response: @escaping Completion<EthData>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_sign",
                params: [message, account, password]
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func signTypedData(
            account: Address,
            data: TypedData,
            password: String,
            response: @escaping Completion<EthData>
        ) {
            let req = RPCRequest<SignTypedDataCallParams>(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_signTypedData",
                params: SignTypedDataCallParams(
                    account: account, data: data, password: password
                )
            )
            
            properties.provider.send(request: req, response: response)
        }
        
        public func ecRecover(
            message: EthData,
            signature: EthData,
            response: @escaping Completion<Address>
        ) {
            let req = BasicRPCRequest(
                id: properties.rpcId,
                jsonrpc: Web3.jsonrpc,
                method: "personal_ecRecover",
                params: [message, signature]
            )
            
            properties.provider.send(request: req, response: response)
        }
    }
}
