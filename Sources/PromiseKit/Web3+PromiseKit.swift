//
//  Web3+PromiseKit.swift
//  Web3
//
//  Created by Koray Koska on 08.03.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import PromiseKit
import Ethereum
#if !COCOAPODS
    import EthereumWeb3
#endif

public extension Web3 {

    func clientVersion() -> Promise<String> {
        return Promise { seal in
            self.clientVersion(response: seal.resolve)
        }
    }
}


public extension Web3.Net {

    func version() -> Promise<String> {
        return Promise { seal in
            self.version(response: seal.resolve)
        }
    }

    func peerCount() -> Promise<Quantity> {
        return Promise { seal in
            self.peerCount(response: seal.resolve)
        }
    }
}


public extension Web3.Eth {

    func protocolVersion() -> Promise<String> {
        return Promise { seal in
            self.protocolVersion(response: seal.resolve)
        }
    }

    func syncing() -> Promise<SyncStatusObject> {
        return Promise { seal in
            self.syncing(response: seal.resolve)
        }
    }

    func mining() -> Promise<Bool> {
        return Promise { seal in
            self.mining(response: seal.resolve)
        }
    }

    func hashrate() -> Promise<Quantity> {
        return Promise { seal in
            self.hashrate(response: seal.resolve)
        }
    }

    func gasPrice() -> Promise<Quantity> {
        return Promise { seal in
            self.gasPrice(response: seal.resolve)
        }
    }

    func accounts() -> Promise<[Address]> {
        return Promise { seal in
            self.accounts(response: seal.resolve)
        }
    }

    func blockNumber() -> Promise<Quantity> {
        return Promise { seal in
            self.blockNumber(response: seal.resolve)
        }
    }

    func getBalance(address: Address, block: QuantityTag = .latest) -> Promise<Quantity> {
        return Promise { seal in
            self.getBalance(address: address, block: block, response: seal.resolve)
        }
    }

    func getStorageAt(
        address: Address,
        position: Quantity,
        block: QuantityTag = .latest
    ) -> Promise<EthData> {
        return Promise { seal in
            self.getStorageAt(address: address, position: position, block: block, response: seal.resolve)
        }
    }

    func getTransactionCount(address: Address, block: QuantityTag = .latest) -> Promise<Quantity> {
        return Promise { seal in
            self.getTransactionCount(address: address, block: block, response: seal.resolve)
        }
    }

    func getBlockTransactionCountByHash(blockHash: EthData) -> Promise<Quantity> {
        return Promise { seal in
            self.getBlockTransactionCountByHash(blockHash: blockHash, response: seal.resolve)
        }
    }

    func getBlockTransactionCountByNumber(block: QuantityTag) -> Promise<Quantity> {
        return Promise { seal in
            self.getBlockTransactionCountByNumber(block: block, response: seal.resolve)
        }
    }

    func getUncleCountByBlockHash(blockHash: EthData) -> Promise<Quantity> {
        return Promise { seal in
            self.getUncleCountByBlockHash(blockHash: blockHash, response: seal.resolve)
        }
    }

    func getUncleCountByBlockNumber(block: QuantityTag) -> Promise<Quantity> {
        return Promise { seal in
            self.getUncleCountByBlockNumber(block: block, response: seal.resolve)
        }
    }

    func getCode(address: Address, block: QuantityTag) -> Promise<EthData> {
        return Promise { seal in
            self.getCode(address: address, block: block, response: seal.resolve)
        }
    }

    func sendRawTransaction(transaction: SignedTransaction) -> Promise<EthData> {
        return Promise { seal in
            self.sendRawTransaction(transaction: transaction, response: seal.resolve)
        }
    }
    
    func sendTransaction(transaction: Transaction) -> Promise<EthData> {
        return Promise { seal in
            self.sendTransaction(transaction: transaction, response: seal.resolve)
        }
    }
    
    func sign(account: Address, message: EthData) -> Promise<EthData> {
        return Promise { seal in
            self.sign(account: account, message: message, response: seal.resolve)
        }
    }
    
    func signTypedData(
        account: Address, data: TypedData
    ) -> Promise<EthData> {
        return Promise { seal in
            self.signTypedData(account: account, data: data, response: seal.resolve)
        }
    }

    func call(call: Call, block: QuantityTag = .latest) -> Promise<EthData> {
        return Promise { seal in
            self.call(call: call, block: block, response: seal.resolve)
        }
    }

    func estimateGas(call: Call) -> Promise<Quantity> {
        return Promise { seal in
            self.estimateGas(call: call, response: seal.resolve)
        }
    }

    func getBlockByHash(blockHash: EthData, fullTransactionObjects: Bool) -> Promise<BlockObject?> {
        return Promise { seal in
            self.getBlockByHash(blockHash: blockHash, fullTransactionObjects: fullTransactionObjects, response: seal.resolve)
        }
    }

    func getBlockByNumber(
        block: QuantityTag,
        fullTransactionObjects: Bool
    ) -> Promise<BlockObject?> {
        return Promise { seal in
            self.getBlockByNumber(block: block, fullTransactionObjects: fullTransactionObjects, response: seal.resolve)
        }
    }

    func getTransactionByHash(blockHash: EthData) -> Promise<TransactionObject?> {
        return Promise { seal in
            self.getTransactionByHash(blockHash: blockHash, response: seal.resolve)
        }
    }

    func getTransactionByBlockHashAndIndex(
        blockHash: EthData,
        transactionIndex: Quantity
    ) -> Promise<TransactionObject?> {
        return Promise { seal in
            self.getTransactionByBlockHashAndIndex(blockHash: blockHash, transactionIndex: transactionIndex, response: seal.resolve)
        }
    }

    func getTransactionByBlockNumberAndIndex(
        block: QuantityTag,
        transactionIndex: Quantity
    ) -> Promise<TransactionObject?> {
        return Promise { seal in
            self.getTransactionByBlockNumberAndIndex(block: block, transactionIndex: transactionIndex, response: seal.resolve)
        }
    }

    func getTransactionReceipt(transactionHash: EthData) -> Promise<TransactionReceiptObject?> {
        return Promise { seal in
            self.getTransactionReceipt(transactionHash: transactionHash, response: seal.resolve)
        }
    }

    func getUncleByBlockHashAndIndex(
        blockHash: EthData,
        uncleIndex: Quantity
    ) -> Promise<BlockObject?> {
        return Promise { seal in
            self.getUncleByBlockHashAndIndex(blockHash: blockHash, uncleIndex: uncleIndex, response: seal.resolve)
        }
    }

    func getUncleByBlockNumberAndIndex(
        block: QuantityTag,
        uncleIndex: Quantity
    ) -> Promise<BlockObject?> {
        return Promise { seal in
            self.getUncleByBlockNumberAndIndex(block: block, uncleIndex: uncleIndex, response: seal.resolve)
        }
    }
    
    func newFilter(
        fromBlock: QuantityTag? = nil,
        toBlock: QuantityTag? = nil,
        address: Address? = nil,
        topics: [Topic]? = nil
    ) -> Promise<Quantity> {
        return Promise { seal in
            self.newFilter(
                fromBlock: fromBlock, toBlock: toBlock,
                address: address, topics: topics,
                response: seal.resolve
            )
        }
    }
    
    func newBlockFilter() -> Promise<Quantity> {
        return Promise { seal in
            self.newBlockFilter(response: seal.resolve)
        }
    }
    
    func newPendingTransactionFilter() -> Promise<Quantity> {
        return Promise { seal in
            self.newPendingTransactionFilter(response: seal.resolve)
        }
    }
    
    func uninstallFilter(id: Quantity) -> Promise<Bool> {
        return Promise { seal in
            self.uninstallFilter(id: id, response: seal.resolve)
        }
    }
    
    func getFilterChanges(id: Quantity) -> Promise<FilterChangesObject> {
        return Promise { seal in
            self.getFilterChanges(id: id, response: seal.resolve)
        }
    }

    
    func getFilterLogs(id: Quantity) -> Promise<[LogObject]> {
        return Promise { seal in
            self.getFilterLogs(id: id, response: seal.resolve)
        }
    }
    
    func getLogs(
        fromBlock: QuantityTag? = nil,
        toBlock: QuantityTag? = nil,
        address: Address? = nil,
        topics: [Topic]? = nil,
        blockhash: EthData? = nil
    ) -> Promise<[LogObject]> {
        return Promise { seal in
            self.getLogs(
                fromBlock: fromBlock, toBlock: toBlock, address: address,
                topics: topics, blockhash: blockhash, response: seal.resolve
            )
        }
    }
}


public extension Web3.Personal {
    
    func importRawKey(privateKey: EthData, password: String) -> Promise<Address> {
        return Promise { seal in
            self.importRawKey(privateKey: privateKey, password: password, response: seal.resolve)
        }
    }
    
    func listAccounts() -> Promise<[Address]> {
        return Promise { seal in
            self.listAccounts(response: seal.resolve)
        }
    }
    
    func newAccount(password: String) -> Promise<Address> {
        return Promise { seal in
            self.newAccount(password: password, response: seal.resolve)
        }
    }
    
    func lockAccount(account: Address) -> Promise<Bool> {
        return Promise { seal in
            self.lockAccount(account: account, response: seal.resolve)
        }
    }
    
    func unlockAccount(
        account: Address,
        password: String,
        duration: Int? = nil
    ) -> Promise<Bool> {
        return Promise { seal in
            self.unlockAccount(
                account: account, password: password,
                duration: duration, response: seal.resolve
            )
        }
    }
    
    func sendTransaction(transaction: Transaction, password: String) -> Promise<EthData> {
        return Promise { seal in
            self.sendTransaction(
                transaction: transaction, password: password,
                response: seal.resolve
            )
        }
    }
    
    func sign(message: EthData, account: Address, password: String) -> Promise<EthData> {
        return Promise { seal in
            self.sign(
                message: message, account: account,
                password: password, response: seal.resolve
            )
        }
    }
    
    func signTypedData(account: Address, data: TypedData, password: String) -> Promise<EthData> {
        return Promise { seal in
            self.signTypedData(
                account: account, data: data,
                password: password, response: seal.resolve
            )
        }
    }
    
    func ecRecover(message: EthData, signature: EthData) -> Promise<Address> {
        return Promise { seal in
            self.ecRecover(message: message, signature: signature, response: seal.resolve)
        }
    }
}
