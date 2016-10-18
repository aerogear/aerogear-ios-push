# aerogear-ios-push [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-push.png)](https://travis-ci.org/aerogear/aerogear-ios-push)

> This module currently build with Xcode 8 and supports iOS8, iOS9 and iOS 10.
> For iOS7 support see [ObjC version in 1.x_dev branch](https://github.com/aerogear/aerogear-ios-push/tree/1.x_dev).

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library written in [Swift 3.0](https://developer.apple.com/swift/) that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | CocoaPods  |
| Documentation:  | https://aerogear.org/docs/unifiedpush/aerogear-push-ios/ |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |

### Build, test and play with aerogear-ios-push

1. Clone this project

2. Get the dependencies

The project uses [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) framework for stubbing its http network requests and utilizes [CocoaPods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [CocoaPods](https://cocoapods.org/) and then install the pod. On the root directory of the project run:
```bash
pod install
```
3. open AeroGearPush.xcworkspace

## Adding the library to your project 
To add the library in your project, you can either use [CocoaPods](http://cocoapods.org) or manual install either by dragging the code or building a ```framework``` to install in your project. See the respective sections below for instructions:

In your ```Podfile``` add:

```
pod 'AeroGear-Push-Swift'
```

and then:

```bash
pod install
```

to install your dependencies

## Example Usage

### Push registration

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

### Push registration using plist config file

In the ```AppDelegate.swift``` file:
```swift
  func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
     // setup registration
    let registration = AGDeviceRegistration()
    
    // attemp to register
    registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in
        // setup configuration
        clientInfo.deviceToken = deviceToken
        let currentDevice = UIDevice()
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

In your application ```info.plist```, add the following properties:
```xml
<plist version="1.0">
<dict>
  <key>serverURL</key>
  <string><# URL of the running AeroGear UnifiedPush Server #></string>
  <key>variantID</key>
  <string><# Variant Id #></string>
  <key>variantSecret</key>
  <string><# Variant Secret #></string>
</dict>
</plist>
```

> NOTE: If your UPS server installation uses a ```self-signed certificate```, you can find a quick solution on how to enable support on our [troubleshooting page](https://aerogear.org/docs/unifiedpush/aerogear-push-ios/troubleshooting/#_question_failure_to_connect_when_server_uses_a_self_signed_certificate), as well as links for further information on how to properly enable it on your iOS production applications.

### Push analytics

If you are interested in monitoring how a push message relates to the usage of your app, you can use metrics. Those emtrics are displayed in the AeroGear UnifiedPush Server's console.

* Send metrics when app is launched due to push notification
```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AGPushAnalytics.sendMetricsWhenAppLaunched(launchOptions)
        return true
    }
```
* Send metrics when the app is brought from background to foreground due to a push notification
```swift
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler: (UIBackgroundFetchResult) -> Void) {      
        // Send metrics when app is launched due to push notification
        AGPushAnalytics.sendMetricsWhenAppAwoken(application.applicationState, userInfo: userInfo)
        
        // Do stuff ...
        fetchCompletionHandler(UIBackgroundFetchResult.NoData)
    }
```

## AeroGear UnifiedPush Server

For more information, checkout our [tutorial](http://aerogear.org/docs/unifiedpush/aerogear-push-ios/).

## Documentation

For more details about the current release, please consult [our documentation](https://aerogear.org/docs/unifiedpush/aerogear-push-ios/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
