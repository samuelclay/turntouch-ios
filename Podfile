platform :ios, "9.0"
use_frameworks!

target "Turn Touch iOS" do
    pod "CocoaAsyncSocket", "~> 7.6"
    pod "AFNetworking/NSURLSession", "~> 3.1"
    pod "SWXMLHash", "~> 4.0.0"
    pod "ReachabilitySwift", "~> 3"
    pod "NestSDK", "0.1.5"
    
    # SwiftyHue
    pod "SwiftyHue", "~> 0.3"
    
    pod "iOSDFULibrary", :git => "https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library.git", :branch => "swift4"
    pod "InAppSettingsKit", "~> 2.8"
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
end

