//
//  Web3HttpTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 14.01.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import EthereumWeb3
#if !COCOAPODS
@testable import PKEthereumWeb3
#endif


class Web3HttpTests: XCTestCase {
    
    func testWeb3ClientVersion() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "web3_clientVersion", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "Geth/v1.8.22-omnibus-260f7fbd/linux-amd64/go1.11.1" }
                  """
        let web3 = MockProvider.web3(method: "web3_clientVersion", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get client version of Web3")
        
        web3.clientVersion() { res in
            let response = try? res.get()
            
            XCTAssertNotNil(response, "should not be nil")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testNetVersion() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "net_version", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "1" }
                  """
        let web3 = MockProvider.web3(method: "net_version", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get net version")

        web3.net.version() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response, "1", "should be mainnet chain id")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testNetPeerCount() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "net_peerCount", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x64" }
                  """
        let web3 = MockProvider.web3(method: "net_peerCount", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get net peer count")

        web3.net.peerCount() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertNotNil(response?.quantity, "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthProtocolVersion() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_protocolVersion", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x3f" }
                  """
        let web3 = MockProvider.web3(method: "eth_protocolVersion", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth protocol version")

        web3.eth.protocolVersion() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthSyncing() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_syncing", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": false }
                  """
        let web3 = MockProvider.web3(method: "eth_syncing", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Check eth syncing")

        web3.eth.syncing() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertNotNil(response?.syncing, "should be a valid response")

            if let b = response?.syncing, b {
                XCTAssertNotNil(response?.startingBlock, "should be a valid response")
                XCTAssertNotNil(response?.currentBlock, "should be a valid response")
                XCTAssertNotNil(response?.highestBlock, "should be a valid response")
            } else {
                XCTAssertNil(response?.startingBlock, "should be a valid response")
                XCTAssertNil(response?.currentBlock, "should be a valid response")
                XCTAssertNil(response?.highestBlock, "should be a valid response")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthMining() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_mining", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": false }
                  """
        let web3 = MockProvider.web3(method: "eth_mining", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Check eth mining")

        web3.eth.mining() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response, false, "should be a bool response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthHashrate() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_hashrate", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x0" }
                  """
        let web3 = MockProvider.web3(method: "eth_hashrate", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth hashrate")

        web3.eth.hashrate() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response?.quantity, 0, "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGasPrice() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_gasPrice", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0xd09dc300" }
                  """
        let web3 = MockProvider.web3(method: "eth_gasPrice", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth gas price")

        web3.eth.gasPrice() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertNotNil(response?.quantity, "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthAccounts() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_accounts", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": [] }
                  """
        let web3 = MockProvider.web3(method: "eth_accounts", req: req, res: res)

        let expectation = XCTestExpectation(description: "Get eth accounts")

        web3.eth.accounts() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response?.count, 0, "should be an array response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthBlockNumber() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_blockNumber", "params": [] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x76c617" }
                  """
        let web3 = MockProvider.web3(method: "eth_blockNumber", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth block number")

        web3.eth.blockNumber() { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertNotNil(response?.quantity, "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGetBalance() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getBalance", "params": ["0xea674fdde714fd979de3edf0f56aa9716b898ec8", "0x3d0900"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x1ea7ab3de3c2f1dc75" }
                  """
        let web3 = MockProvider.web3(method: "eth_getBalance", req: req, res: res)
        
        let e = try? Address(hex: "0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8", eip55: false)
        XCTAssertNotNil(e, "should not be nil")
        guard let ethereumAddress = e else { return }

        let expectation = XCTestExpectation(description: "Get eth balance")

        web3.eth.getBalance(address: ethereumAddress, block: .block(4000000)) { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response?.quantity, BigUInt("1ea7ab3de3c2f1dc75", radix: 16), "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGatStorageAt() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getStorageAt", "params": ["0x06012c8cf97bead5deae237070f9587f8e7a266d", "0x0", "latest"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x000000000000000000000000af1e54b359b0897133f437fc961dd16f20c045e1" }
                  """
        let web3 = MockProvider.web3(method: "eth_getStorageAt", req: req, res: res)
        
        let e = try? Address(hex: "0x06012c8cf97BEaD5deAe237070F9587f8E7A266d", eip55: false)
        XCTAssertNotNil(e, "should not be nil")
        guard let ethereumAddress = e else { return }

        let expectation = XCTestExpectation(description: "Get eth storage at")

        web3.eth.getStorageAt(address: ethereumAddress, position: 0, block: .latest) { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response?.hex, "0x000000000000000000000000af1e54b359b0897133f437fc961dd16f20c045e1", "should be a data response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGetTransactionCount() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getTransactionCount", "params": ["0x464b0b37db1ee1b5fbe27300acfbf172fd5e4f53", "0x3d0900"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0xd8" }
                  """
        let web3 = MockProvider.web3(method: "eth_getTransactionCount", req: req, res: res)
        
        let e = try? Address(hex: "0x464B0B37db1eE1b5Fbe27300aCFBf172fD5E4F53", eip55: false)
        XCTAssertNotNil(e, "should not be nil")
        guard let ethereumAddress = e else { return }

        let expectation = XCTestExpectation(description: "Get eth transaction count")

        web3.eth.getTransactionCount(address: ethereumAddress, block: .block(4000000)) { res in
            let response = try? res.get()

            XCTAssertNotNil(response, "should not be nil")
            XCTAssertEqual(response?.quantity, 0xd8, "should be a quantity response")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGetTransactionCountByHash() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getBlockTransactionCountByHash", "params": ["0x596f2d863a893392c55b72b5ba29e9ba67bdaa13c31765f9119e850a62565960"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0xaa" }
                  """
        let web3 = MockProvider.web3(method: "eth_getBlockTransactionCountByHash", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth transaction count by hash")

        XCTAssertNotNil(
            try? web3.eth.getBlockTransactionCountByHash(blockHash: .string("0x596f2d863a893392c55b72b5ba29e9ba67bdaa13c31765f9119e850a62565960")) { res in
                let response = try? res.get()

                XCTAssertNotNil(response, "should not be nil")
                XCTAssertEqual(response?.quantity, 0xaa, "should be a quantity response")

                expectation.fulfill()
            }
            , "should not throw an error"
        )

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGetTransactionCountByNumber() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getBlockTransactionCountByNumber", "params": ["0x525b8d"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x58" }
                  """
        let web3 = MockProvider.web3(method: "eth_getBlockTransactionCountByNumber", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth transaction count by number")

        firstly {
            web3.eth.getBlockTransactionCountByNumber(block: .block(5397389))
        }.done { count in
            XCTAssertEqual(count, 88, "should be count 88")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthUncleCountByBlockHash() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getUncleCountByBlockHash", "params": ["0xd8cdd624c5b4c5323f0cb8536ca31de046e3e4a798a07337489bab1bb3d822f0"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x1" }
                  """
        let web3 = MockProvider.web3(method: "eth_getUncleCountByBlockHash", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth uncle count by block hash")

        firstly {
            try web3.eth.getUncleCountByBlockHash(blockHash: .string("0xd8cdd624c5b4c5323f0cb8536ca31de046e3e4a798a07337489bab1bb3d822f0"))
        }.done { count in
            XCTAssertEqual(count, 1, "should include one uncle")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthUncleCountByBlockNumber() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getUncleCountByBlockNumber", "params": ["0x525bb5"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x1" }
                  """
        let web3 = MockProvider.web3(method: "eth_getUncleCountByBlockNumber", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get eth uncle count by block number")

        firstly {
            web3.eth.getUncleCountByBlockNumber(block: .block(5397429))
        }.done { count in
            XCTAssertEqual(count, 1, "should include one uncle")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthGetCode() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_getCode", "params": ["0x2e704bf506b96adac7ad1df0db461344146a4657", "0x525c15"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x60606040526004361061006c5763ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663022914a78114610071578063173825d9146100a457806341c0e1b5146100c55780637065cb48146100d8578063aa1e84de146100f7575b600080fd5b341561007c57600080fd5b610090600160a060020a036004351661015a565b604051901515815260200160405180910390f35b34156100af57600080fd5b6100c3600160a060020a036004351661016f565b005b34156100d057600080fd5b6100c36101b7565b34156100e357600080fd5b6100c3600160a060020a03600435166101ea565b341561010257600080fd5b61014860046024813581810190830135806020601f8201819004810201604051908101604052818152929190602084018383808284375094965061023595505050505050565b60405190815260200160405180910390f35b60006020819052908152604090205460ff1681565b600160a060020a03331660009081526020819052604090205460ff16151561019657600080fd5b600160a060020a03166000908152602081905260409020805460ff19169055565b600160a060020a03331660009081526020819052604090205460ff1615156101de57600080fd5b33600160a060020a0316ff5b600160a060020a03331660009081526020819052604090205460ff16151561021157600080fd5b600160a060020a03166000908152602081905260409020805460ff19166001179055565b6000816040518082805190602001908083835b602083106102675780518252601f199092019160209182019101610248565b6001836020036101000a0380198251168184511617909252505050919091019250604091505051809103902090509190505600a165627a7a7230582085affe2ee33a8eb3900e773ef5a0d7f1bc95448e61a845ef36e00e6d6b4872cf0029" }
                  """
        let web3 = MockProvider.web3(method: "eth_getCode", req: req, res: res)

        let expectation = XCTestExpectation(description: "Get eth code")

        firstly {
            try web3.eth.getCode(address: Address(hex: "0x2e704bF506b96adaC7aD1df0db461344146a4657", eip55: true), block: .block(5397525))
        }.done { code in
            let data: EthData? = try? .string("0x60606040526004361061006c5763ffffffff7c0100000000000000000000000000000000000000000000000000000000600035041663022914a78114610071578063173825d9146100a457806341c0e1b5146100c55780637065cb48146100d8578063aa1e84de146100f7575b600080fd5b341561007c57600080fd5b610090600160a060020a036004351661015a565b604051901515815260200160405180910390f35b34156100af57600080fd5b6100c3600160a060020a036004351661016f565b005b34156100d057600080fd5b6100c36101b7565b34156100e357600080fd5b6100c3600160a060020a03600435166101ea565b341561010257600080fd5b61014860046024813581810190830135806020601f8201819004810201604051908101604052818152929190602084018383808284375094965061023595505050505050565b60405190815260200160405180910390f35b60006020819052908152604090205460ff1681565b600160a060020a03331660009081526020819052604090205460ff16151561019657600080fd5b600160a060020a03166000908152602081905260409020805460ff19169055565b600160a060020a03331660009081526020819052604090205460ff1615156101de57600080fd5b33600160a060020a0316ff5b600160a060020a03331660009081526020819052604090205460ff16151561021157600080fd5b600160a060020a03166000908152602081905260409020805460ff19166001179055565b6000816040518082805190602001908083835b602083106102675780518252601f199092019160209182019101610248565b6001836020036101000a0380198251168184511617909252505050919091019250604091505051809103902090509190505600a165627a7a7230582085affe2ee33a8eb3900e773ef5a0d7f1bc95448e61a845ef36e00e6d6b4872cf0029")
            XCTAssertEqual(code, data, "should be the expected data")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthCall() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_call", "params": [{"data": "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000", "to": "0x2e704bf506b96adac7ad1df0db461344146a4657"}, "latest"] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x5e2393c41c2785095aa424cf3e033319468b6dcebda65e61606ee2ae2a198a87" }
                  """
        let web3 = MockProvider.web3(method: "eth_call", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Check eth call")

        firstly {
            web3.eth.call(
                call: try Call(
                    from: nil,
                    to: Address(hex: "0x2e704bf506b96adac7ad1df0db461344146a4657", eip55: false),
                    gas: nil,
                    gasPrice: nil,
                    value: nil,
                    data: EthData(
                        ethereumValue: "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"
                    )
                ),
                block: .latest
            )
        }.done { data in
            let expectedData: EthData = try .string("0x5e2393c41c2785095aa424cf3e033319468b6dcebda65e61606ee2ae2a198a87")
            XCTAssertEqual(data, expectedData, "should be the expected data")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testEthEstimateGas() {
        let req = """
                    { "id": 1, "jsonrpc": "2.0", "method": "eth_estimateGas", "params": [{"to": "0x2e704bf506b96adac7ad1df0db461344146a4657", "data": "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"}] }
                  """
        let res = """
                    { "id": 1, "jsonrpc": "2.0", "result": "0x58dc" }
                  """
        let web3 = MockProvider.web3(method: "eth_estimateGas", req: req, res: res)
        
        let expectation = XCTestExpectation(description: "Get gas estimate")

        firstly {
            web3.eth.estimateGas(call:
                try Call(
                    from: nil,
                    to: Address(hex: "0x2e704bf506b96adac7ad1df0db461344146a4657", eip55: false),
                    gas: nil,
                    gasPrice: nil,
                    value: nil,
                    data: EthData(
                        ethereumValue: "0xaa1e84de000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000046461766500000000000000000000000000000000000000000000000000000000"
                    )
                )
            )
        }.done { quantity in
            let expectedQuantity: Quantity = try .string("0x58dc")
            XCTAssertEqual(quantity, expectedQuantity, "should be the expected quantity")

            expectation.fulfill()
        }.catch { err in
            XCTFail("should not fail, error: \(err)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
