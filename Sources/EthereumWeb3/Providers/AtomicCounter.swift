//
//  AtomicCounter.swift
//  Web3
//
//  Created by Yehor Popovych on 3/16/19.
//

import Foundation

public class AtomicCounter {
    private var _value: UInt32
    private let _lock: NSLock
    
    public init() {
        self._value = 0
        self._lock = NSLock()
    }
    
    public func next() -> UInt32 {
        _lock.lock()
        defer { _lock.unlock() }
        _value = _value == UInt32.max ? 1 : _value + 1
        return _value
    }
}
