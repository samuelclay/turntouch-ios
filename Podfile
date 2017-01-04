platform :ios, "9.0"
use_frameworks!

target "Turn Touch iOS" do
    pod "CocoaAsyncSocket", "~> 7.4.3"
    pod "AFNetworking", "~> 3.0"
    pod "SWXMLHash", "~> 3.0.0"
    pod "ReachabilitySwift", "~> 3"
    pod "NestSDK", "0.1.5"
    
    # SwiftyHue
    pod "SwiftyHue", :git => "https://github.com/samuelclay/SwiftyHue.git", :branch => "swift3"
    
    pod "iOSDFULibrary", "~> 3.0"
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

