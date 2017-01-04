# SDK for the Nest API on iOS [Unofficial]

[![CI Status](https://travis-ci.org/petroakzhygitov/nest-ios-sdk.svg?branch=master&style=flat)](https://travis-ci.org/petroakzhygitov/nest-ios-sdk)
[![Version](https://img.shields.io/cocoapods/v/NestSDK.svg?style=flat)](http://cocoapods.org/pods/NestSDK)
[![License](https://img.shields.io/cocoapods/l/NestSDK.svg?style=flat)](http://cocoapods.org/pods/NestSDK)
[![Platform](https://img.shields.io/cocoapods/p/NestSDK.svg?style=flat)](http://cocoapods.org/pods/NestSDK) 

This open-source library allows you to integrate Nest API into your iOS app.

Learn more about Nest API at https://developer.nest.com/documentation/cloud/get-started

## Example

To run the example project, clone the repo, and run `pod install` from the `NestSDKDemo`, `NestSDKDemoAdvanced` or `NestSDKDemoSwift` directory first.

## Installation

NestSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NestSDK", "0.1.5"
```

## General Nest product setup

To work with NestSDK you need to have Nest Product created. If you already have one, you may skip this section, if not, follow these steps:

1. Create your Nest developers account at [https://home.nest.com] (https://home.nest.com/login/?style=default&next=%2Faccounts%2Fsaml2%2Fidp%2Fcomplete%3FSAMLRequest%3DPHNhbWxwOkF1dGhuUmVxdWVzdCBBc3NlcnRpb25Db25zdW1lclNlcnZpY2VVUkw9J2h0dHBzOi8vZGV2ZWxvcGVyLm5lc3QuY29tL2F1dGgvc2FtbC9zZXNzaW9ucycgRGVzdGluYXRpb249J2h0dHBzOi8vaG9tZS5uZXN0LmNvbS9hY2NvdW50cy9zYW1sMi9pZHAvcG9zdD9zdHlsZT1kZWZhdWx0JyBJRD0nXzJjNzBjYjQwLTk5YmYtMDEzMy05NmM1LTIyMDAwYjIyMDZiMCcgSXNQYXNzaXZlPSdmYWxzZScgSXNzdWVJbnN0YW50PScyMDE2LTAxLTEwVDExOjU2OjU3WicgVmVyc2lvbj0nMi4wJyB4bWxuczpzYW1sPSd1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uJyB4bWxuczpzYW1scD0ndXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sJz48c2FtbDpJc3N1ZXI%252BaHR0cHM6Ly9kZXZlbG9wZXIubmVzdC5jb208L3NhbWw6SXNzdWVyPjxzYW1scDpOYW1lSURQb2xpY3kgQWxsb3dDcmVhdGU9J3RydWUnIEZvcm1hdD0ncm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6cHJvdG9jb2wnLz48L3NhbWxwOkF1dGhuUmVxdWVzdD4%253D#/sign-up)

2. Create your Nest Product at [https://developer.nest.com/products/new] (https://developer.nest.com/products/new)

3. Indicate `Redirect URI`. Do not leave text field empty, since PIN-based Authorization is not supported.

4. Use your product `Product ID`, `Product Secret` and `Redirect URI` for the iOS project setup.

## General iOS project setup

Any iOS project should be properly setup in order to use NestSDK. Follow these steps to setup your iOS project:

1. Add NestSDK to your project (see Installation)

2. Configure the `.plist` for your project:

  In Xcode right-click your `.plist` file and choose "Open As Source Code".
  Copy & Paste the XML snippet into the body of your file (`<dict>...</dict>`).

  ```
	<key>NestProductID</key>
	<string>{your-product-id}</string>
	<key>NestProductSecret</key>
	<string>{your-product-secret}</string>
	<key>NestRedirectURL</key>
	<string>{your-product-redirect-url}</string>
  ```

  Replace:
    - `{your-product-id}` with your product `Product ID`.
    - `{your-product-secret}` with your product `Product Secret`.
    - `{your-product-redirect-url}` with your product `Redirect URI`.

3. Connect Application Delegate

  Conenct your `AppDelegate` to the `NestSDKApplicationDelegate`. In your `AppDelegate.m` add:
  
  `Objective-C`
  ```objective-c
  //  AppDelegate.m
  #import <NestSDK/NestSDK.h>

  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	  [[NestSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
  
	  return YES;
  }
  ```
  `Swift`
  ```swift
  //  AppDelegate.swift
  import NestSDK

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
	  NestSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

	  return true
  }
  ```

## General iOS application workflow

Before reading, observing or updating any data to Nest devices or structures you should implement user authorization. So, the general application workflow should be the following:

1. Authorize user with Nest using predefined `Connect with Nest` button (`NestSDKConnectWithNestButton`) or by manually handling authorization dialog with authorization manager class (`NestSDKAuthorizationManager`).

2. Read/Observe/Update devices, structures or meta data.

## Connect with Nest

The Nest SDK for iOS enables users to connect your Nest product app with their's personal Nest account. 
When users connect their's personal Nest account with your Nest product app they grant permissions to your app so 
you can retrieve and modify information on their behalf.

**NB:** Connect with Nest **supports Web-based Authorization** only. **PIN-based Authorization** is **not supported**.

[More information](https://developer.nest.com/documentation/cloud/authorization-overview) about Nest authorization.

### Add Connect with Nest button code

To add a `Connect with Nest` button to your app add the following code snippet to a view controller:

`Objective-C`
```objective-c
// Add this to the header of your file, e.g. in ViewController.m 
// after #import "ViewController.h"
#import <NestSDK/NestSDK.h>

// Add this to the body
@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
  
	NestSDKConnectWithNestButton *connectWithNestButton = [[NestSDKConnectWithNestButton alloc] init];
  
	// Optional: Place the button in the center of your view.
	connectWithNestButton.center = self.view.center;
  
	[self.view addSubview:connectWithNestButton];
}
    
@end
```

`Swift`
```swift
// Add this to the top of your file, e.g. in ViewController.swift 
// after import UIKit
import NestSDK

// Add this to the class body
override func viewDidLoad() {
	super.viewDidLoad()
      
	let connectWithNestButton = NestSDKConnectWithNestButton(frame: CGRectMake(0, 0, 200, 44))
  
	// Optional: Place the button in the center of your view.
	connectWithNestButton.center = self.view.center
  
	view.addSubview(connectWithNestButton)
}
```

To know whether user is already authorized check the result of `[NestSDKAccessToken currentToken]` before starting authorization process:

`Objective-C`
```objective-c

if ([NestSDKAccessToken currentToken]) {
	NSLog(@"Authorized!");
  
} else {
	NSLog(@"Not authorized!);
}
```

`Swift`
```swift

if (NestSDKAccessToken.currentAccessToken() != nil) {
	print("Authorized!")
	
} else {
	print("Not authorized!")
}
```
### Custom Connect with Nest button

Instead of using the predefined `Connect with Nest` button (explained in Add Connect with Nest button code) you may want to design a custom layout and behavior. In the following code example we invoke the authorization dialog using the authorization manager class (`NestSDKAuthorizationManager`) and a custom button (`UIButton`). You can use any other custom user interface or event handling to invoke the authorization dialog.

`Objective-C`
```objective-c
// Add this to the header of your file
#import "ViewController.h"
#import <NestSDK/NestSDK.h>

// Add this to the body
@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
	// Add a custom connect with button to your app
	UIButton *customConnectWithNestButton = [UIButton buttonWithType:UIButtonTypeCustom];
	customConnectWithNestButton.backgroundColor = [UIColor darkGrayColor];
	customConnectWithNestButton.frame = CGRectMake(0, 0, 240, 40);

	// Optional: Place the button in the center of your view.
	customConnectWithNestButton.center = self.view.center;
	[customConnectWithNestButton setTitle:@"Custom Connect Button" forState:UIControlStateNormal];

	// Handle clicks on the button
	[customConnectWithNestButton addTarget:self action:@selector(customConnectWithNestButtonClicked)
			              forControlEvents:UIControlEventTouchUpInside];

	// Add the button to the view
	[self.view addSubview:customConnectWithNestButton];
}

// Once the button is clicked, show the auth dialog
- (void)customConnectWithNestButtonClicked {
	NestSDKAuthorizationManager *authorizationManager = [[NestSDKAuthorizationManager alloc] init];
	[authorizationManager authorizeWithNestAccountFromViewController:self
                                                             	 handler:^(NestSDKAuthorizationManagerAuthorizationResult *result, NSError *error) {
                                                                     if (error) {
							         	                                 NSLog(@"Process error: %@", error);
								
								                                     } else if (result.isCancelled) {
								                                         NSLog(@"Cancelled");
								
								                                     } else {
								                                         NSLog(@"Authorized!");
								                                     }
                                                                 }];
}
    
@end
```

`Swift`
```swift
// Add this to the top of your file, e.g. in ViewController.swift 
import UIKit
import NestSDK

// Add this to the class body
override func viewDidLoad() {
	super.viewDidLoad()
    
	// Add a custom connect with button to your app
	let customConnectWithNestButton = UIButton(type: .Custom)
	customConnectWithNestButton.backgroundColor = UIColor.darkGrayColor()
	customConnectWithNestButton.frame = CGRectMake(0, 0, 240, 40)
    
	// Optional: Place the button in the center of your view.
	customConnectWithNestButton.center = self.view.center
	customConnectWithNestButton.setTitle("Custom Connect Button", forState:.Normal)
    
	// Handle clicks on the button
	customConnectWithNestButton.addTarget(self, action: "customConnectWithNestButtonClicked:", forControlEvents: .TouchUpInside)
    
	// Add the button to the view
	self.view.addSubview(customConnectWithNestButton)
}

// Once the button is clicked, show the auth dialog
func customConnectWithNestButtonClicked(sender:UIButton!) {
	let authorizationManager = NestSDKAuthorizationManager()
	authorizationManager.authorizeWithNestAccountFromViewController(self, handler:{
		result, error in

		if (error == nil) {
			print("Process error: \(error)")

		} else if (result.isCancelled) {
			print("Cancelled")

		} else {
			print("Authorized!")
		}
	})
}
```

## Accessing structures

All Nest devices belong to a structure. Structure can have many devices. 

It's possible that user has more than one structure attached to their Nest Account, so your product should offer means for the user to choose from the available structures (a structure picker).

[More information](https://developer.nest.com/documentation/cloud/structure-guide) about Nest structures.

### Observing structures

To observe structures use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];
[dataManager observeStructuresWithBlock:^(NSArray <NestSDKStructure> *structuresArray, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while observing structures: %@", error);
		return;
	}
	
	for (NestSDKStructure *structure in structuresArray) {
		NSLog(@"Updated structure with name: %@", structure.name);
	}
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()
dataManager.observeStructuresWithBlock({
	structuresArray, error in
	
	if (error == nil) {
		print("Error occurred while observing structures: \(error)")
		return
	}
	
	for structure in structuresArray as! [NestSDKStructure] {
		print("Updated structure with name: \(structure.name)")
	}
})
```
### Reading structures

In general it is better to observe structures rather than read them, since you will be updated with any changes happen. 

In case you want simply read structures use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];
[dataManager structuresWithBlock:^(NSArray <NestSDKStructure> *structuresArray, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while reading structures: %@", error);
		return;
	}
	
	for (NestSDKStructure *structure in structuresArray) {
		NSLog(@"Read structure with name: %@", structure.name);
	}
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()
dataManager.structuresWithBlock({
	structuresArray, error in
	
	if (error == nil) {
		print("Error occurred while reading structures: \(error)")
		return
	}
	
	for structure in structuresArray as! [NestSDKStructure] {
		print("Read structure with name: \(structure.name)")
	}
})
```
### Updating structures

It is possible to update structure's `away` status and set `eta`. To update a structure use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];
[dataManager setStructure:structure block:^(id <NestSDKStructure> structure, NSError *) {
	if (error) {
		NSLog(@"Error occurred while updating structure: %@", error);
		return;
	}
	
	NSLog(@"Updated structure with name: %@", structure.name);
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()
dataManager.setStructure(structure, block:{
	structure, error in
	
	if (error == nil) {
		print("Error occurred while updating structures: \(error)")
		return
	}
	
	print("Updated structure with name: \(structure.name)")
})
```

## Accessing devices

There are three types of Nest devices available to read/observe/update:
- Thermostat ([more information](https://developer.nest.com/documentation/cloud/thermostat-guide))
- Smoke+CO Alarm ([more information](https://developer.nest.com/documentation/cloud/smoke-co-guide))
- Camera ([more information](https://developer.nest.com/documentation/cloud/camera-guide))

**NB:** Ensure you have set proper permissions to read specific device data with your [Nest Product](https://developer.nest.com/products).

### Observing devices

To observe devices use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];

NSString *thermostatId = structure.thermostats[someIndex];
[self.dataManager observeThermostatWithId:thermostatId block:^(id <NestSDKThermostat> thermostat, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while observing thermostat: %@", error);
		return;
	}
	
	NSLog(@"Updated thermostat with name: %@", thermostat.name);
}];

NSString *smokeCOAlarmId = structure.smokeCoAlarms[someIndex];
[self.dataManager observeSmokeCOAlarmWithId:smokeCOAlarmId block:^(id <NestSDKSmokeCOAlarm> smokeCOAlarm, NSError *error) {
    	if (error) {
		NSLog(@"Error occurred while observing smoke CO alarm: %@", error);
		return;
	}
	
	NSLog(@"Updated smoke+CO Alarm with name: %@", smokeCOAlarm.name);
}];
 
NSString *cameraId = structure.cameras[someIndex];
[self.dataManager observeCameraWithId:cameraId block:^(id <NestSDKCamera> camera, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while observing camera: %@", error);
		return;
	}
	
	NSLog(@"Updated camera with name: %@", camera.name);
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()

let thermostatId = structure.thermostats[someIndex] as! String
dataManager.observeThermostatWithId(thermostatId, block:{
	thermostat, error in
	
	if (error == nil) {
		print("Error occurred while observing thermostat \(error)")
		return
	}
	
	print("Updated thermostat with name \(thermostat.name)")
})

let smokeCOAlarmId = structure.smokeCoAlarms[someIndex] as! String
dataManager.observeSmokeCOAlarmWithId(smokeCOAlarmId, block:{
    	smokeCOAlarm, error in
    	
    	if (error == nil) {
		print("Error occurred while observing smoke CO alarm \(error)")
		return
	}
	
	print("Updated smoke+CO Alarm with name \(smokeCOAlarm.name)")
})
 
let cameraId = structure.cameras[someIndex] as! String
dataManager.observeCameraWithId(cameraId, block:{
	camera, error in
	
	if (error == nil) {
		print("Error occurred while observing camera \(error)")
		return
	}
	
	print("Updated camera with name \(camera.name)")
})
```

### Reading devices

In general it is better to observe devices rather than read them, since you will be updated with any changes happen. 

In case you want simply read devices use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];

NSString *thermostatId = structure.thermostats[someIndex];
[self.dataManager thermostatWithId:thermostatId block:^(id <NestSDKThermostat> thermostat, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while reading thermostat: %@", error);
		return;
	}
	
	NSLog(@"Read thermostat with name: %@", thermostat.name);
}];

NSString *smokeCOAlarmId = structure.smokeCoAlarms[someIndex];
[self.dataManager smokeCOAlarmWithId:smokeCOAlarmId block:^(id <NestSDKSmokeCOAlarm> smokeCOAlarm, NSError *error) {
    	if (error) {
		NSLog(@"Error occurred while reading smoke CO alarm: %@", error);
		return;
	}
	
	NSLog(@"Read smoke+CO Alarm with name: %@", smokeCOAlarm.name);
}];
 
NSString *cameraId = structure.cameras[someIndex];
[self.dataManager cameraWithId:cameraId block:^(id <NestSDKCamera> camera, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while reading camera: %@", error);
		return;
	}
	
	NSLog(@"Read camera with name: %@", camera.name);
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()

let thermostatId = structure.thermostats[someIndex] as! String
dataManager.thermostatWithId(thermostatId, block:{
	thermostat, error in
    
	if (error == nil) {
		print("Error occurred while reading thermostat \(error)")
		return
	}
    
	print("Read thermostat with name \(thermostat.name)")
})

let smokeCOAlarmId = structure.smokeCoAlarms[someIndex] as! String
dataManager.smokeCOAlarmWithId(smokeCOAlarmId, block:{
	smokeCOAlarm, error in
    
	if (error == nil) {
		print("Error occurred while reading smoke CO alarm \(error)")
		return
	}
    
	print("Read smoke+CO Alarm with name \(smokeCOAlarm.name)")
})

let cameraId = structure.cameras[someIndex] as! String
dataManager.cameraWithId(cameraId, block:{
	camera, error in
    
	if (error == nil) {
		print("Error occurred while reading camera \(error)")
		return
	}
    
	print("Read camera with name \(camera.name)")
})
```

### Updating devices

- It is possible to update thermostat's `fanTimerActive`, `fanTimerTimeout`, `targetTemperatureF`, `targetTemperatureC`, `targetTemperatureHighF`, `targetTemperatureHighC`, `targetTemperatureLowF`, `targetTemperatureLowC` and `hvacMode` values.
- It is possible to update camera's `isStreaming` status.
- It is **not possible** to update satuses/values for **smoke+CO alarm** device.

To update devices use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];

[self.dataManager setThermostat:thermostat block:^(id <NestSDKThermostat> thermostat, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while updating thermostat: %@", error);
		return;
	}
	
	NSLog(@"Updated thermostat with name: %@", thermostat.name);
}];

[self.dataManager setCamera:camera block:^(id <NestSDKCamera> camera, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while updating camera: %@", error);
		return;
	}
	
	NSLog(@"Updated camera with name: %@", camera.name);
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()

dataManager.setThermostat(thermostat, block:{
	thermostat, error in
	
	if (error == nil) {
		print("Error occurred while updating thermostat \(error)")
		return
	}
	
	print("Updated thermostat with name \(thermostat.name)")
})

dataManager.setCamera(camera, block:{
	camera, error in
	
	if (error == nil) {
		print("Error occurred while updating camera \(error)")
		return
	}
	
	print("Updated camera with name \(camera.name)")
})
```

## Accessing metadata

Data about the data. Metadata values cannot be accessed directly and have no associated permissions.

### Reading metadata

To read metadata use `NestSDKDataManager`:

`Objective-C`
```objective-c
NestSDKDataManager *dataManager = [[NestSDKDataManager alloc] init];

[self.dataManager metadataWithBlock:^(id <NestSDKMetadata> metadata, NSError *error) {
	if (error) {
		NSLog(@"Error occurred while reading metadata: %@", error);
		return;
	}
	
	NSLog(@"Read metadata: %@", metadata);
}];
```

`Swift`
```swift
let dataManager = NestSDKDataManager()

dataManager.metadataWithBlock({
	metadata, error in
	
	if (error == nil) {
		print("Error occurred while reading metadata \(error)")
		return
	}
	
	print("Read metadata \(metadata)")
})
```

## Author

Petro Akzhygitov (petro.akzhygitov@gmail.com)

## License

NestSDK is available under the MIT license. See the LICENSE file for more info.
