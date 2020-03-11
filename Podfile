platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

def source
  pod 'RxSwift', '~> 4.3'
  pod 'RxCocoa', '~> 4.3'
  pod 'RxDataSources', '~> 3.1'
end

target 'Flix' do
  source

    target 'FlixTests' do
        inherit! :search_paths
    end
end

target 'Example' do
  source
  pod 'RxKeyboard', :git => 'https://github.com/RxSwiftCommunity/RxKeyboard.git', :branch => 'swift-4.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
