platform :ios, "12.0"
use_frameworks!

target "Turn Touch iOS" do
    pod "CocoaAsyncSocket", "~> 7.6"
    pod "AFNetworking/NSURLSession", "~> 3.1"
    pod "SWXMLHash", "~> 4.4"
    pod "ReachabilitySwift", "~> 4.0"
    pod "NestSDK", "0.1.5"
    
    # SwiftyHue
    pod "SwiftyHue", "~> 0.5"
    
    pod "iOSDFULibrary", "~> 4.0"
    pod "InAppSettingsKit", "~> 2.8"
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
end

