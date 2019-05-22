//
//  FileManager+loadStub.swift
//  EthereumWeb3
//
//  Created by Yura Kulynych on 5/22/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation


public extension FileManager {
    static func loadStub(named: String) -> Data? {
        #if os(Linux) || os(FreeBSD)
        let path = "Tests/EthereumWeb3Tests/Stubs/\(named).json"
        let url = URL(fileURLWithPath: path)
        return try? Data(contentsOf: url)
        #else
        let bundle = Bundle(for: MockProvider.self)
        
        if let path = bundle.path(forResource: named, ofType: "json") {
            // XCTest
            let url = URL(fileURLWithPath: path)
            return try? Data(contentsOf: url)
        } else {
            // Swift Package Manager (https://bugs.swift.org/browse/SR-4725)
            // let basePath = bundle.bundlePath
            // let url = URL(fileURLWithPath: basePath + "/../../../../Tests/Web3Tests/Stubs/\(named).json")
            // return try? Data(contentsOf: url)
            let path = "Tests/EthereumWeb3Tests/Stubs/\(named).json"
            let url = URL(fileURLWithPath: path)
            return try? Data(contentsOf: url)
        }
        #endif
    }
}
