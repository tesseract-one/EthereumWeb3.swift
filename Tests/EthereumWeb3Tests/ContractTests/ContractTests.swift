//
//  ContractTests.swift
//  Web3_Tests
//
//  Created by Josh Pyles on 6/7/18.
//

import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif

extension Address {
    static let testAddress = try! Address(hex: "0x0000000000000000000000000000000000000000", eip55: false)
}

public extension XCTestCase {
    
    func loadStub(named: String) -> Data? {
        #if os(Linux) || os(FreeBSD)
        let path = "Tests/EthereumWeb3Tests/Stubs/\(named).json"
        let url = URL(fileURLWithPath: path)
        return try? Data(contentsOf: url)
        #else
        let bundle = Bundle(for: type(of: self))

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
    
    class MockWeb3DataProvider: DataProvider {
        public func send(data: Data, response: @escaping (Swift.Result<Data, Error>) -> Void) {}
    }

    class MockWeb3Provider: Provider {
        public var dataProvider: DataProvider = MockWeb3DataProvider()
    
        var stubs: [String: Data] = [:]
    
        func addStub(method: String, data: Data) {
            stubs[method] = data
        }
    
        func removeStub(method: String) {
            stubs[method] = nil
        }
    
        public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Completion<Result>) {
            if let stubbedData = stubs[request.method] {
                do {
                    let rpcResponse = try JSONDecoder().decode(RPCResponse<Result>.self, from: stubbedData)
                    response(Swift.Result(rpcResponse: rpcResponse))
                } catch {
                    response(.failure(.decodingError(error)))
                }
            } else {
                response(.failure(.serverError(nil)))
            }
        }
    
    }
}

// Example of subclassing a common token implementation
class TestContract: GenericERC721Contract {

    private let byteCode = try! EthData(ethereumValue: "0x0123456789ABCDEF")

    // Example of a static constructor
    func deploy(name: String) -> SolidityConstructorInvocation {
        let constructor = SolidityConstructor(inputs: [SolidityFunctionParameter(name: "_name", type: .string)], handler: self)
        return constructor.invoke(byteCode: byteCode, parameters: [name])
    }

    // Example of a static function
    func buyToken() -> SolidityInvocation {
        let method = SolidityPayableFunction(name: "buyToken", inputs: [], outputs: nil, handler: self)
        return method.invoke()
    }
}

class ContractTests: XCTestCase {
    
    func stubResponses(provider: MockWeb3Provider) {
        if let transactionData = loadStub(named: "sendTransaction") {
            provider.addStub(method: "eth_sendTransaction", data: transactionData)
        }
        
        if let receiptData = loadStub(named: "getTransactionReceipt") {
            provider.addStub(method: "eth_getTransactionReceipt", data: receiptData)
        }
        
        if let callData = loadStub(named: "call_getBalance") {
            provider.addStub(method: "eth_call", data: callData)
        }
        
        if let gasData = loadStub(named: "estimateGas") {
            provider.addStub(method: "eth_estimateGas", data: gasData)
        }
    }
    
    func getWeb3() -> Web3 {
        let provider = MockWeb3Provider()
        stubResponses(provider: provider)
        return Web3(provider: provider)
    }
    
    func getContract() -> TestContract {
        return getWeb3().eth.Contract(type: TestContract.self, address: .testAddress)
    }
    
    func testConstructorMethod() {
        let expectation = XCTestExpectation(description: "Contract should be able to be deployed")
        
        getContract()
            .deploy(name: "Test Instance")
            .send(from: .testAddress, value: 0, gas: 15000, gasPrice: nil)
            .done { hash in
                expectation.fulfill()
            }.catch { err in
                XCTFail("should not fail, error: \(err)")
                
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testConstantMethod() {
        let invocation = getContract().balanceOf(address: .testAddress)
        
        let expectation1 = XCTestExpectation(description: "Invocation should succeed with call")
        let expectation2 = XCTestExpectation(description: "Invocation should fail with send")
        
        invocation.call()
            .done { values in
                XCTAssertEqual(values["_balance"] as? BigUInt, 1, "should succeed with call")
                
                expectation1.fulfill()
            }.catch { err in
                XCTFail("should not fail, error: \(err)")
                
                expectation1.fulfill()
            }
        
        invocation.send(from: .testAddress, value: nil, gas: 0, gasPrice: 0)
            .catch { error in
                XCTAssertEqual(error as? InvocationError, InvocationError.invalidInvocation, "should fail with send")
                
                expectation2.fulfill()
            }
        
        
        wait(for: [expectation1, expectation2], timeout: 2.0)
    }
    
    func testPayableMethod() {
        let invocation = getContract().buyToken()
        
        let expectation1 = XCTestExpectation(description: "Invocation should estimate gas")
        let expectation2 = XCTestExpectation(description: "Invocation should succeed with send")
        let expectation3 = XCTestExpectation(description: "Invocation should fail with call")
        
        firstly {
            invocation.estimateGas(from: .testAddress, value: Quantity(BigUInt(10).power(18)))
        }.done { gas in
            expectation1.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")
            
            expectation1.fulfill()
        }
        
        let expectedHash = try! EthData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")
        firstly {
            invocation.send(from: .testAddress, value: Quantity(BigUInt(10).power(18)), gas: 21000, gasPrice: nil)
        }.done { hash in
            XCTAssertEqual(hash, expectedHash, "should succeed with send")
            
            expectation2.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")
            
            expectation2.fulfill()
        }
        
        invocation.call()
            .catch { error in
                XCTAssertEqual(error as? InvocationError, .invalidInvocation, "should fail with call")
                
                expectation3.fulfill()
            }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 2.0)
    }
    
    func testNonPayableMethod() {
        let invocation = getContract().transfer(to: .testAddress, tokenId: 1)
        
        let expectation1 = XCTestExpectation(description: "Invocation should succeed with send")
        let expectation2 = XCTestExpectation(description: "Invocation should fail with call")
        
        let expectedHash = try! EthData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")
        invocation.send(from: .testAddress, value: nil, gas: 12000, gasPrice: 700000)
            .done { hash in
                XCTAssertEqual(hash, expectedHash, "should succeed with send")
                
                expectation1.fulfill()
            }.catch { err in
                XCTFail("should not fail, error: \(err)")
                
                expectation1.fulfill()
            }
        
        invocation.call()
            .catch { error in
                XCTAssertEqual(error as? InvocationError, .invalidInvocation, "should fail with call")
                
                expectation2.fulfill()
            }
        
        wait(for: [expectation1, expectation2], timeout: 2.0)
    }
    
    func testEvent() {
        let hash = try! EthData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")
        
        let expectation = XCTestExpectation(description: "Event should be decoded from a matching log")
        
        firstly {
            getWeb3().eth.getTransactionReceipt(transactionHash: hash)
        }.done { receipt in
            if let logs = receipt?.logs {
                for log in logs {
                    if let _ = try? ABI.decodeLog(event: TestContract.Transfer, from: log) {
                        expectation.fulfill()
                        break
                    }
                }
            }
        }.catch { err in
            XCTFail("should not fail, error: \(err)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
