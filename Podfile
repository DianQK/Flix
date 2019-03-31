platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

def source
  pod 'RxSwift', '~> 4.4'
  pod 'RxCocoa', '~> 4.4'
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
  pod 'RxKeyboard', '~> 0.9'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
