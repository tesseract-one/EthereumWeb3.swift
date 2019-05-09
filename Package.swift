// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "EthereumWeb3",
    products: [
        .library(name: "EthereumWeb3", targets: ["EthereumWeb3"]),
        .library(name: "PKEthereumWeb3", targets: ["PKEthereumWeb3"])
    ],
    dependencies: [
        // Ethereum
        .package(url: "https://github.com/tesseract-one/EthereumTypes.swift.git", from: "0.1.0"),
        // PromiseKit
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.0")
    ],
    targets: [
        .target(
            name: "EthereumWeb3",
            dependencies: ["Ethereum"]
        ),
        .target(
            name: "PKEthereumWeb3",
            dependencies: ["EthereumWeb3", "PromiseKit"],
            path: "Sources/PromiseKit"
        ),
        .testTarget(
            name: "EthereumWeb3Tests",
            dependencies: ["EthereumWeb3", "PKEthereumWeb3"]
        )
    ]
)
