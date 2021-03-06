//
//  EthereumFilterEngine.swift
//  Web3
//
//  Created by Yehor Popovych on 3/16/19.
//

import Foundation
import Ethereum

public class FilterEngine {
    public enum Error: Swift.Error {
        case filterNotFound(Quantity)
    }
    
    private let provider: Provider
    
    private var timer: DispatchSourceTimer?
    
    private var lastFilterId: UInt64
    
    private var blockFilters: Dictionary<UInt64, BlockFilterProtocol>
    private var pendingBlockFilters: Dictionary<UInt64, BlockFilterProtocol>
    private var logFilters: Dictionary<UInt64, LogsFilterProtocol>
    private let counter: AtomicCounter
    
    private var lastBlock: BlockObject?
    
    private var lock: NSLock
    
    private let checkInterval: TimeInterval = 4.0
    private let filterLifeTime: TimeInterval = 300.0
    
    public init(provider: Provider, counter: AtomicCounter) {
        self.provider = provider
        self.timer = nil
        self.lastFilterId = 0
        self.blockFilters = [:]
        self.pendingBlockFilters = [:]
        self.logFilters = [:]
        self.lock = NSLock()
        self.counter = counter
        self.lastBlock = nil
    }
    
    public func addLogsFilter(filter: LogsFilterProtocol) -> Quantity {
        lock.lock()
        defer { lock.unlock() }
        lastFilterId += 1
        logFilters[lastFilterId] = filter
        _checkTimer()
        return Quantity(integerLiteral: lastFilterId)
    }
    
    public func addBlockFilter(filter: BlockFilterProtocol) -> Quantity {
        lock.lock()
        defer { lock.unlock() }
        lastFilterId += 1
        blockFilters[lastFilterId] = filter
        _checkTimer()
        return Quantity(integerLiteral: lastFilterId)
    }
    
    public func addPendingBlockFilter(filter: BlockFilterProtocol) -> Quantity {
        lock.lock()
        defer { lock.unlock() }
        lastFilterId += 1
        pendingBlockFilters[lastFilterId] = filter
        _checkTimer()
        return Quantity(integerLiteral: lastFilterId)
    }
    
    public func removeFilter(id: Quantity) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let intId = UInt64(id.quantity)
        let result = logFilters.removeValue(forKey: intId) != nil
            || blockFilters.removeValue(forKey: intId) != nil
            || pendingBlockFilters.removeValue(forKey: intId) != nil
        _checkTimer()
        return result
    }
    
    public func getFilterChages(id: Quantity) throws -> FilterChangesObject {
        lock.lock()
        defer { lock.unlock() }
        let intId = UInt64(id.quantity)
        if var filter = logFilters[intId] {
            let changes = filter.getFilterChanges()
            logFilters[intId] = filter
            return .logs(changes)
        } else if var filter = blockFilters[intId] {
            let changes = filter.getFilterChanges()
            blockFilters[intId] = filter
            return .hashes(changes)
        } else if var filter = pendingBlockFilters[intId] {
            let changes = filter.getFilterChanges()
            pendingBlockFilters[intId] = filter
            return .hashes(changes)
        }
        throw Error.filterNotFound(id)
    }
    
    public func getFilterLogs(
        id: Quantity,
        cb: @escaping (Swift.Result<[LogObject], ProviderError>) -> Void
    ) {
        lock.lock()
        let filter = logFilters[UInt64(id.quantity)]
        lock.unlock()
        if let filter = filter {
            let req = RPCRequest<[GetLogsParams]>(
                id: Int(counter.next()),
                jsonrpc: Web3.jsonrpc,
                method: "eth_getLogs",
                params: [GetLogsParams(
                    fromBlock: filter.fromBlock,
                    toBlock: filter.toBlock,
                    address: filter.address,
                    topics: filter.topics
                )]
            )
            provider.send(request: req, response: cb)
        } else {
            DispatchQueue.global().async {
                cb(.failure(.requestFailed(Error.filterNotFound(id))))
            }
        }
    }
    
    // Thread unsafe
    private func _checkTimer() {
        if let timer = self.timer {
            if logFilters.count + blockFilters.count + pendingBlockFilters.count == 0 {
                timer.cancel()
                self.timer = nil
            }
        } else {
            if logFilters.count + blockFilters.count + pendingBlockFilters.count > 0 {
                let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
                timer.setEventHandler { [weak self] in
                    self?._tick()
                }
                timer.schedule(deadline: .now() , repeating: 4.0)
                timer.resume()
                self.timer = timer
            }
        }
    }
    
    // Thread unsafe
    private func _clearOutdatedFilters() {
        let now = Date(timeIntervalSinceNow: 0.0)
        blockFilters = blockFilters.filter { _, filter in
            now.timeIntervalSince(filter.lastFetched) < self.filterLifeTime
        }
        logFilters = logFilters.filter { _, filter in
            now.timeIntervalSince(filter.lastFetched) < self.filterLifeTime
        }
        pendingBlockFilters = pendingBlockFilters.filter { _, filter in
            now.timeIntervalSince(filter.lastFetched) < self.filterLifeTime
        }
    }
    
    private func _tick() {
        lock.lock()
        _clearOutdatedFilters()
        _checkTimer()
        let hasBlock = blockFilters.count + logFilters.count > 0
        let hasPending = pendingBlockFilters.count > 0
        lock.unlock()
        if hasBlock {
            _updateLastBlock()
        }
        if hasPending {
            _updatePendingBlock()
        }
    }
    
    private func _updateLastBlock() {
        let req = BasicRPCRequest(
            id: Int(counter.next()),
            jsonrpc: Web3.jsonrpc,
            method: "eth_getBlockByNumber",
            params: [QuantityTag.latest, false]
        )
        provider.send(request: req) { (response: Swift.Result<BlockObject, ProviderError>) in
            if let block = try? response.get() {
                self.lock.lock()
                self.blockFilters = self.blockFilters.mapValues { filter in
                    var mFilter = filter
                    mFilter.apply(block: block)
                    return mFilter
                }
                let hasLogs = self.logFilters.count > 0
                self.lock.unlock()
                if hasLogs {
                    self._updateLogs(block: block)
                }
            }
        }
    }
    
    private func _updatePendingBlock() {
        let req = BasicRPCRequest(
            id: Int(counter.next()),
            jsonrpc: Web3.jsonrpc,
            method: "eth_getBlockByNumber",
            params: [QuantityTag.pending, false]
        )
        provider.send(request: req) { (response: Swift.Result<BlockObject, ProviderError>) in
            if let block = try? response.get() {
                self.lock.lock()
                self.pendingBlockFilters = self.pendingBlockFilters.mapValues { filter in
                    var mFilter = filter
                    mFilter.apply(block: block)
                    return mFilter
                }
                self.lock.unlock()
            }
        }
    }
    
    private func _updateLogs(block: BlockObject) {
        lock.lock()
        guard lastBlock == nil || lastBlock!.number!.quantity < block.number!.quantity else {
            lock.unlock()
            return
        }
        lastBlock = block
        lock.unlock()
        let req = RPCRequest<[GetLogsParams]>(
            id: Int(counter.next()),
            jsonrpc: Web3.jsonrpc,
            method: "eth_getLogs",
            params: [GetLogsParams(blockhash: block.hash!)]
        )
        provider.send(request: req) { (response: Swift.Result<[LogObject], ProviderError>) in
            if let logs = try? response.get() {
                self.lock.lock()
                self.logFilters = self.logFilters.mapValues { filter in
                    var mFilter = filter
                    mFilter.apply(block: block, logs: logs)
                    return mFilter
                }
                self.lock.unlock()
            }
        }
    }
    
    deinit {
        self.timer?.cancel()
        self.timer = nil
    }
}
