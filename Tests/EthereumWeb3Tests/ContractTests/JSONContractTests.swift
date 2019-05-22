////
////  JSONContractTests.swift
////  Web3_Tests
////
////  Created by Josh Pyles on 6/4/18.
////
//
import XCTest
import Foundation

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif

class JSONContractTests: XCTestCase {
    
    func testJSONGeneratedContract() {
        let web3 = Web3(provider: MockProvider())

        guard let abiData = FileManager.loadStub(named: "LimitedMintableNonFungibleToken") else {
            XCTFail("Could not load stub")
            return
        }
        let contract = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress)
        
        XCTAssertNotNil(contract, "should not be nil")
        XCTAssertEqual(contract?.methods.count, 16, "should be decoded properly")
    }

    func testConstructorMethods() {
        guard let abiData = FileManager.loadStub(named: "LimitedMintableNonFungibleToken") else {
            XCTFail("Could not load stub")
            return
        }
        guard let rawByteCode = try? JSONDecoder().decode(SerializableValue.self, from: abiData).object!["bytecode"]?.string else {
            XCTFail("Could not get bytecode")
            return
        }
        guard let byteCode = try? EthData(ethereumValue: rawByteCode) else {
            XCTFail("Bytecode is incorrect")
            return
        }
        
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_sendTransaction", "params": [{ "gas": "0x3a98", "value": "0x0", "data": "\(rawByteCode)0000000000000000000000000000000000000000000000000000000000000005", "from": "0x0000000000000000000000000000000000000000" }] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331" }
                  """
        let web3 = MockProvider.web3(method: "eth_sendTransaction", req: req, res: res)
        
        let contract = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress)
        guard let invocation = contract?.deploy(byteCode: byteCode, parameters: BigUInt(5)) else {
            XCTFail("Could not create invocation")
            return
        }

        XCTAssertNotNil(contract?.constructor, "should have constructor method")

        XCTAssertEqual(invocation.parameters.count, 1, "should have correct invocation")
        XCTAssertEqual(invocation.byteCode, byteCode, "should have correct invocation")

        let transaction = invocation.createTransaction(from: .testAddress, gas: 0, gasPrice: 0)
        let generatedHexString = transaction?.data?.hex
        XCTAssertNotNil(generatedHexString, "should be able to create a valid transaction")

        let expectedHash = try? EthData(ethereumValue: "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331")

        let expectation1 = XCTestExpectation(description: "Invocation should deploy")
        let expectation2 = XCTestExpectation(description: "Invocation should fail to deploy when including a value")

        invocation.send(from: .testAddress, gas: 15000) { res in
            let hash = try? res.get()

            XCTAssertEqual(hash, expectedHash, "should deploy")

            expectation1.fulfill()
        }

        invocation.send(from: .testAddress, value: Quantity(BigUInt(10).power(18)), gas: 15000) { res in
            do {
                let _ = try res.get()

                XCTFail("should fail to deploy when including a value")

                expectation2.fulfill()
            } catch {
                XCTAssertEqual(error as? InvocationError, .invalidInvocation, "should fail to deploy when including a value")

                expectation2.fulfill()
            }
        }

        wait(for: [expectation1, expectation2], timeout: 2.0)
    }

    func testCalls() {
        var req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_call", "params": [{ "to": "0x0000000000000000000000000000000000000000", "data": "0x70a082310000000000000000000000000000000000000000000000000000000000000000"}, "latest" ]}
                   """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0000000000000000000000000000000000000000000000000000000000000001" }
                   """
        var web3 = MockProvider.web3(method: "eth_call", req: req, res: res)
        
        guard let abiData = FileManager.loadStub(named: "LimitedMintableNonFungibleToken") else {
            XCTFail("Could not load stub")
            return
        }
        guard let contract = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress) else {
            XCTFail("Could not create contract")
            return
        }
        
        let expectation1 = XCTestExpectation(description: "Contract should be able to call constant method")
        let expectation2 = XCTestExpectation(description: "Contract should be able to create an Call")
        
        contract["balanceOf"]?(Address.testAddress).call() { res in
            let response = try? res.get()
            
            XCTAssertNotNil(response, "should be able to call constant method")
            XCTAssertEqual(response?["_balance"] as? BigUInt, 1, "should be able to call constant method")
            
            expectation1.fulfill()
        }
        
        req = """
                { "id": 1, "jsonrpc": "2.0", "method": "eth_call", "params": [{ "to": "0x0000000000000000000000000000000000000000", "data": "0x70a082310000000000000000000000000000000000000000000000000000000000000000" }, "latest" ]}
              """
        web3 = MockProvider.web3(method: "eth_call", req: req, res: res)
        
        guard let call = contract["balanceOf"]?(Address.testAddress).createCall() else {
            XCTFail("Could not generate call")
            return
        }
        web3.eth.call(call: call, block: .latest) { res in
            let response = try? res.get()
            XCTAssertNotNil(response, "should be able to create an Call")
            
            expectation2.fulfill()
        }
        
        wait(for: [expectation1, expectation2], timeout: 2.0)
    }
    
    func testSends() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_sendTransaction", "params": [{ "nonce": "0x0", "gas": "0x2ee0", "to": "0x0000000000000000000000000000000000000000", "value": "0x0", "data": "0x23b872dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", "from": "0x0000000000000000000000000000000000000000" }] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0e670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331" }
                  """
        let web3 = MockProvider.web3(method: "eth_sendTransaction", req: req, res: res)
        
        guard let abiData = FileManager.loadStub(named: "LimitedMintableNonFungibleToken") else {
            XCTFail("Could not load stub")
            return
        }
        guard let contract = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress) else {
            XCTFail("Could not create contract")
            return
        }
        guard let transaction = contract["transferFrom"]?(Address.testAddress, Address.testAddress, BigUInt(1)).createTransaction(nonce: 0, from: .testAddress, value: nil, gas: 12000, gasPrice: nil) else {
            XCTFail("Could not generate transaction")
            return
        }

        let expectation = XCTestExpectation(description: "Contract should be able to send non-payable method")

        web3.eth.sendTransaction(transaction: transaction) { res in
            let response = try? res.get()
            
            XCTAssertNotNil(response, "should be able to create a Call")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testJSONContractWithStructTypes () {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_call", "params": [{ "to": "0x0000000000000000000000000000000000000000", "data": "0x548213850000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002" }, "latest"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004" }
                  """
        let web3 = MockProvider.web3(method: "eth_call", req: req, res: res)
        
        guard let abiData = FileManager.loadStub(named: "TupleExample") else {
            XCTFail("Could not load stub")
            return
        }
        guard let contract = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress) else {
            XCTFail("Could not create contract")
            return
        }
       
        let expectation = XCTestExpectation(description: "Contract should represent structs with tuples")
        
        firstly {
            contract["f"]!(SolidityTuple(.uint(BigUInt(1)), .uint(BigUInt(2))), BigUInt(3)).call()
        }.done { outputs in
            guard let t = outputs["t"] as? [String: Any] else {
                XCTFail("returned tuple should be decoded")
                return
            }
            
            XCTAssertEqual(t["x"] as? BigUInt, 3, "should represent structs with tuples")
            XCTAssertEqual(t["y"] as? BigUInt, 4, "should represent structs with tuples")
            
            expectation.fulfill()
        }.catch { err in
            XCTFail("should represent structs with tuples, error: \(err)")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testJSONContractWithFallbackFunction() {
        let web3 = Web3(provider: MockProvider())
        
        guard let abiData = FileManager.loadStub(named: "Fallback") else {
            XCTFail("Could not load stub")
            return
        }
        guard let _ = try? web3.eth.Contract(json: abiData, abiKey: "abi", address: .testAddress) else {
            XCTFail("Could not create contract")
            return
        }
    }
}
