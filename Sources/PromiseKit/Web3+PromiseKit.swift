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
}

