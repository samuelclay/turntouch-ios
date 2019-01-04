# Turn Touch iOS App
> A native Swift app for configuring and using the Turn Touch smart wooden remote.

[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

App | Modes
:----:|:----:
| ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.17%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.22%20PM.png) |

How It Works | Tap a button | Hold a button | Multiple actions | HUD
:---:|:---:|:---:|:---:|:---:
| ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.48%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.51%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.52%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.53%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%207,%202016,%20Sep%207%206.10.55%20PM.png) |

## Features

- [x] Feature 1
- [x] Feature 2
- [x] Feature 3
- [x] Feature 4
- [x] Feature 5

## Requirements

- iOS 8.0+
- Xcode 7.3

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install `YourLibrary` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!
pod 'YourLibrary'
```

To get the full benefits import `YourLibrary` wherever you import UIKit

``` swift
import UIKit
import YourLibrary
```
#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/YourLibrary.framework` to an iOS project.

```
github "yourUsername/yourlibrary"
```
#### Manually
1. Download and drop ```YourLibrary.swift``` in your project.  
2. Congratulations!  

## Usage example

```swift
import EZSwiftExtensions
ez.detectScreenShot { () -> () in
    print("User took a screen shot")
}
```

## Contribute

We would love you for the contribution to the **Turn Touch iOS app**. 

Here's what you will need to do to add a new app:

1. Copy one of the [/Turn Touch iOS/Modes](Turn%20Touch%20iOS/Modes) apps. If you can't choose, use the Music app, as it's pretty easy to clean.
2. Add your app to the list of available apps in [/Turn Touch iOS/Models/TTModeMap.swift](Turn%20Touch%20iOS/Models/TTModeMap.swift)
3. Make sure to test on your iOS device
4. Submit a Pull Request with the app improvement or addition.

## Turn Touch open source repositories and documentation

Everything about Turn Touch is open source and well documented. Here are all of Turn Touch's repos:

* [Turn Touch Mac OS app](https://github.com/samuelclay/turntouch-app/)
* [Turn Touch iOS app](https://github.com/samuelclay/turntouch-ios/)
* [Turn Touch remote firmware and board layout](https://github.com/samuelclay/turntouch-remote/)
* [Turn Touch enclosure, CAD, and CAM](https://github.com/samuelclay/turntouch-enclosure/)

The entire Turn Touch build process is also documented:
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/">Everything you need to build your own Turn Touch smart remote<br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*1_w7IlHISYWdQjIGPcxRkQ.jpeg" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#firmware">Step one: Laying out the buttons and writing the firmware <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*K_ERgjIZiFIX5yDOa5JJ7g.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#cad">Step two: Designing the remote to have perfect button clicks <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*iXMqpq5IsfudAeT3GZlLFA.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#cnc">Step three: CNC machining and fixturing to accurately cut wood <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*SYmywFE5tY3GBO9t9lcTiA.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#laser">Step four: Inlaying the mother of pearl <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*kl8WDuTd0RpCkkipLeHx0g.png" width="400"></a>

## Author

Samuel Clay – [@samuelclay](https://twitter.com/samuelclay) – [samuelclay.com](http://samuelclay.com)

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/samuelclay/turntouch-ios](https://github.com/samuelclay)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
