Pod::Spec.new do |s|
  s.name             = 'Tesseract.EthereumWeb3'
  s.version          = '0.1.2'
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

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'EthereumWeb3'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/EthereumWeb3/**/*.swift'

    ss.dependency 'Tesseract.EthereumTypes', '~> 0.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'Tesseract.EthereumWeb3/Core'
    ss.dependency 'PromiseKit/CorePromise', '~> 6.8'
  end

  s.default_subspecs = 'Core'
end
