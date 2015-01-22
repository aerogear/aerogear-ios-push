# aerogear-ios-push [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-push.png)](https://travis-ci.org/aerogear/aerogear-ios-push)

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library written in [Swift](https://developer.apple.com/swift/) that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

### Build, test and play with aerogear-ios-push

1. Clone this project

2. Get the dependencies

The project uses [aerogear-ios-httpstub](https://github.com/aerogear/aerogear-ios-httpstub) framework for stubbing its http network requests and utilizes [cocoapods](http://cocoapods.org) 0.36.0 pre-release for handling its dependencies. As a pre-requisite, install [cocoapods pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) and then install the pod. On the root directory of the project run:
```bash
pod install
```
3. open AeroGearPushSwift.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [Cocoapods](http://cocoapods.org) or manual install in your project. See the respective sections below for instructions:

### Using [Cocoapods](http://cocoapods.org)
At this time, Cocoapods support for Swift frameworks is supported in a [pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/). In your ```Podfile``` add:

```
pod 'AeroGear-Push-Swift'
```

and then:

```bash
pod install
```

to install your dependencies

### Manual Installation
Follow these steps to add the library in your Swift project:

1. Add AeroGearPush as a [submodule](http://git-scm.com/docs/git-submodule) in your project. Open a terminal and navigate to your project directory. Then enter:
```bash
git submodule add https://github.com/aerogear/aerogear-ios-push.git
```
2. Open the `aerogear-ios-push` folder, and drag the `AeroGearPush.xcodeproj` into the file navigator in Xcode.
3. In Xcode select your application target  and under the "Targets" heading section, ensure that the 'iOS  Deployment Target'  matches the application target of AeroGearPush.framework (Currently set to 8.0).
5. Select the  "Build Phases"  heading section,  expand the "Target Dependencies" group and add  `AeroGearPush.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `AeroGearPush.framework`.


If you run into any problems, please [file an issue](http://issues.jboss.org/browse/AEROGEAR) and/or ask our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users). You can also join our [dev mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev).  

## Example Usage

```swift
  func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
     // setup registration
    let registration = AGDeviceRegistration(serverURL: NSURL(string: "<# URL of the running AeroGear UnifiedPush Server #>")!)
    
    // attemp to register
    registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in
        // setup configuration
        clientInfo.deviceToken = deviceToken
        clientInfo.variantID = "<# Variant Id #>"
        clientInfo.variantSecret = "<# Variant Secret #>"
        
        // apply the token, to identify THIS device
        let currentDevice = UIDevice()
        
        // --optional config--
        // set some 'useful' hardware information params
        clientInfo.operatingSystem = currentDevice.systemName
        clientInfo.osVersion = currentDevice.systemVersion
        clientInfo.deviceType = currentDevice.model
        },
        
        success: {
            println("UnifiedPush Server registration succeeded")
        },
        failure: {(error: NSError!) in
            println("failed to register, error: \(error.description)")
        })
}
```

## AeroGear UnifiedPush Server

For more information, checkout our [tutorial](http://aerogear.org/docs/unifiedpush/aerogear-push-ios/).
