# EthereumWeb3.swift

[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](https://raw.githubusercontent.com/tesseract-one/EthereumWeb3.swift/master/LICENSE)
[![Build Status](https://travis-ci.com/tesseract-one/EthereumWeb3.swift.svg?branch=master)](https://travis-ci.com/tesseract-one/EthereumWeb3.swift)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/EthereumWeb3.swift.svg)](https://github.com/tesseract-one/EthereumWeb3.swift/releases)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Tesseract.EthereumWeb3.svg)](https://cocoapods.org/pods/Tesseract.EthereumWeb3)
![Platform iOS](https://img.shields.io/badge/platform-iOS-orange.svg)

## Ethereum Web3 Lirary for Swift with Open Wallet support

## Goals

This library intergates [Boilertalk/Web3.swift](https://github.com/Boilertalk/Web3.swift) library with [OpenWallet.swift](https://github.com/tesseract-one/OpenWallet.swift) and [Wallet.swift](https://github.com/tesseract-one/Wallet.swift).

It supports major Ethereum Web3 methods through HTTP.

## Getting started

### Installation

#### With [OpenWallet.swift](https://github.com/tesseract-one/OpenWallet.swift) (Client)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'Tesseract.OpenWallet/Ethereum'
pod 'Tesseract.EthereumWeb3'

# Uncomment this lines if you want to enable PromiseKit extensions
# pod 'Tesseract.OpenWallet/EthereumPromiseKit'
# pod 'Tesseract.EthereumWeb3/PromiseKit'
```

Then run `pod install`.

#### With [Wallet.swift](https://github.com/tesseract-one/Wallet.swift) (Wallet)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'Tesseract.Wallet/Ethereum'
pod 'Tesseract.EthereumWeb3'

# Uncomment this lines if you want to enable PromiseKit extensions
# pod 'Tesseract.Wallet/EthereumPromiseKit'
# pod 'Tesseract.EthereumWeb3/PromiseKit'
```

Then run `pod install`.

### Supported methods

For the list of supported methods and API reference check [Boilertalk/Web3.swift](https://github.com/Boilertalk/Web3.swift) repository.

### Examples

#### [OpenWallet.swift](https://github.com/tesseract-one/OpenWallet.swift) (Client)

##### New transaction

```swift
import OpenWallet
import EthereumWeb3

// HTTP RPC URL
let rpcUrl = "https://mainnet.infura.io/v3/{API-KEY}"

// Initializing OpenWallet with Ethereum. Creating Web3 instance
// Store your OpenWallet instance somewhere(AppDelegate, Context). It should be reused.
// If you need only Web3, you can store it only(it will store OpenWallet inside itself).
let web3 = OpenWallet(networks: [.Ethereum]).ethereum.web3(rpcUrl: rpcUrl)

// Creating Transaction
let tx = EthereumTransaction(
    from: try! EthereumAddress(hex: "0x...", eip55: false),
    to: try! EthereumAddress(hex: "0x...", eip55: false),
    value: 1.eth
)

// Sending it. OpenWallet will handle signing automatically.
web3.eth.sendTransaction(transaction: tx) { response in
    switch response.status {
    case .success(let hash): print("TX Hash:", hash.hex())
    case .failure(let err): print("Error:", error)
    }
}
```

#### [Wallet.swift](https://github.com/tesseract-one/Wallet.swift) (Wallet)

##### New transaction

```swift
import Wallet
import EthereumWeb3

// Path to sqlite database with wallets
let dbPath = "path/to/database.sqlite"

// Wallet Storage
let storage = try! DatabaseWalletStorage(path: dbPath)

// Applying migrations
try! storage.bootstrap()

// Creating manager with Ethereum network support
let manager = try! Manager(networks: [EthereumNetwork()], storage: storage)

// Restoring wallet data from mnemonic
let walletData = try! manager.restoreWalletData(mnemonic: "aba caba ...", password: "12345678")

// Creating wallet from data
let wallet = try! manager.create(from: walletData)

// Unlocking wallet
try! wallet.unlock(password: "12345678")

// Adding first account 
let account = wallet.addAccount()

// HTTP RPC URL
let rpcUrl = "https://mainnet.infura.io/v3/{API-KEY}"

// Creating Web3 for this Wallet
let web3 = wallet.ethereum.web3(rpcUrl: rpcUrl)

// Creating Transaction
let tx = EthereumTransaction(
    from: try! account.eth_address().web3,
    to: try! EthereumAddress(hex: "0x...", eip55: false),
    value: 1.eth
)

// Wallet will sign this transaction automatically (with 'from' account)
web3.eth.sendTransaction(transaction: tx) { response in
    switch response.status {
    case .success(let hash): print("TX Hash:", hash.hex())
    case .failure(let err): print("Error:", error)
    }
}
```

## Author

 - [Tesseract Systems, Inc.](mailto:info@tesseract.one)
   ([@tesseract_one](https://twitter.com/tesseract_one))

## License

`OEthereumWeb3.swift` is available under the Apache 2.0 license. See [the LICENSE file](https://raw.githubusercontent.com/tesseract-one/EthereumWeb3.swift/master/LICENSE) for more information.
