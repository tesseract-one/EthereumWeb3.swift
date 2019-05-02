use_frameworks!
inhibit_all_warnings!

def common_pods
    pod 'Tesseract.EthereumTypes', '~> 0.1'    
    pod 'Web3', :git => 'https://github.com/tesseract-one/Web3.swift.git', :branch => 'master'
    pod 'PromiseKit/CorePromise', '~> 6.8'
end

target 'EthereumWeb3-iOS' do
    platform :ios, '10.0'

    common_pods
end

target 'EthereumWeb3Tests-iOS' do
    platform :ios, '10.0'

    common_pods
end
