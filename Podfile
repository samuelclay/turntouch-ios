platform :ios, "12.0"
use_frameworks!

# Ignore all warnings from all pods
inhibit_all_warnings!

target "Turn Touch iOS" do
    pod "CocoaAsyncSocket", "~> 7.6"
    pod "AFNetworking/NSURLSession", "~> 3.1"
    pod "SWXMLHash", "~> 4.4"
    pod "ReachabilitySwift", "~> 4.0"
    pod "NestSDK", "0.1.5"
    
    # SwiftyHue
    pod "SwiftyHue", "~> 0.5"
    
    pod "iOSDFULibrary", "~> 4.11.1"
    pod "InAppSettingsKit", "~> 2.8"
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
