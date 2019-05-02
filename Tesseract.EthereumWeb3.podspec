Pod::Spec.new do |s|
  s.name             = 'Tesseract.EthereumWeb3'
  s.version          = '0.1.0'
  s.summary          = 'Tesseract Ethereum Web3 library with signing support for Swift'

  s.description      = <<-DESC
Web3 library which can be used with Tesseract Open Wallet or Tesseract Wallet libraries for signing.
Supports eth, net and personal RPC api. Filters handled by polling on client.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/EthereumWeb3.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/EthereumWeb3.swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '10.0'

  s.module_name = 'EthereumWeb3'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/EthereumWeb3/**/*.swift'

    ss.dependency 'Tesseract.EthereumTypes', '~> 0.1'
    ss.dependency 'Web3', '~> 0.3.1'
    ss.dependency 'Web3/ContractABI', '~> 0.3.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.dependency 'Tesseract.EthereumWeb3/Core'
    ss.dependency 'Web3/PromiseKit', '~> 0.3.1'
  end

  s.default_subspecs = 'Core'
end
