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
    
    func getContract(web3: Web3) -> TestContract {
        return web3.eth.Contract(type: TestContract.self, address: .testAddress)
    }
    
    func testConstructorMethod() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_sendTransaction", "params": [{ "value": "0x0", "gas": "0x3a98", "data": "0x0123456789abcdef0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000d5465737420496e7374616e636500000000000000000000000000000000000000", "from": "0x0000000000000000000000000000000000000000" }] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331" }
                  """
        let web3 = MockProvider.web3(method: "eth_sendTransaction", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Contract should be able to be deployed")
        
        getContract(web3: web3)
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
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_call", "params": [{ "to": "0x0000000000000000000000000000000000000000", "data": "0x70a082310000000000000000000000000000000000000000000000000000000000000000"}, "latest" ] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0000000000000000000000000000000000000000000000000000000000000001" }
                  """
        let web3 = MockProvider.web3(method: "eth_call", req: req, res: res)

        
        let invocation = getContract(web3: web3).balanceOf(address: .testAddress)

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
        let req1 = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_estimateGas", "params": [{ "value": "0xde0b6b3a7640000", "to": "0x0000000000000000000000000000000000000000", "data": "0xa4821719", "from": "0x0000000000000000000000000000000000000000" }] }
                   """
        let res1 = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x5208" }
                   """
        let req2 = """
                    { "id": 2, "jsonrpc": "2.0", "method": "eth_sendTransaction", "params": [{ "value": "0xde0b6b3a7640000", "gas": "0x5208", "to": "0x0000000000000000000000000000000000000000", "data": "0xa4821719", "from": "0x0000000000000000000000000000000000000000" }] }
                   """
        let res2 = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331" }
                   """
        let provider = MockProvider()
        provider.addMethod(method: "eth_estimateGas", req: req1, res: res1)
        provider.addMethod(method: "eth_sendTransaction", req: req2, res: res2)
        let web3 = Web3(provider: provider)
        
        let invocation = getContract(web3: web3).buyToken()

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
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_sendTransaction", "params": [{"value": "0x0", "gas": "0x2ee0", "to": "0x0000000000000000000000000000000000000000", "data": "0xa9059cbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "gasPrice": "0xaae60", "from": "0x0000000000000000000000000000000000000000" }] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331" }
                  """
        let web3 = MockProvider.web3(method: "eth_sendTransaction", req: req, res: res)
        
        let invocation = getContract(web3: web3).transfer(to: .testAddress, tokenId: 1)

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
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getTransactionReceipt", "params": ["0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331"] }
                  """
        guard let res = String(data: FileManager.loadStub(named: "TransactionReceipt")!, encoding: .utf8) else {
            XCTFail("Could not load stub")
            return
        }
        let web3 = MockProvider.web3(method: "eth_getTransactionReceipt", req: req, res: res)
        
        let hash = try! EthData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")

        let expectation = XCTestExpectation(description: "Event should be decoded from a matching log")

        firstly {
            web3.eth.getTransactionReceipt(transactionHash: hash)
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
