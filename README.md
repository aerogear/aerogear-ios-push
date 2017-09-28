# AeroGear iOS Push

![Maintenance](https://img.shields.io/maintenance/yes/2017.svg)
[![circle-ci](https://img.shields.io/circleci/project/github/aerogear/aerogear-ios-push/master.svg)](https://circleci.com/gh/aerogear/aerogear-ios-push)
[![License](https://img.shields.io/badge/-Apache%202.0-blue.svg)](https://opensource.org/s/Apache-2.0)
[![GitHub release](https://img.shields.io/github/release/aerogear/aerogear-ios-push.svg)](https://github.com/aerogear/aerogear-ios-push/releases)
[![CocoaPods](https://img.shields.io/cocoapods/v/AeroGear-Push-Swift.svg)](https://cocoapods.org/pods/AeroGear-Push-Swift)
[![Platform](https://img.shields.io/cocoapods/p/AeroGear-Push-Swift.svg)](https://cocoapods.org/pods/AeroGear-Push-Swift)

A handy library that helps to register iOS applications with the AeroGear UnifiedPush Server.

|                 | Project Info                                 |
| --------------- | -------------------------------------------- |
| License:        | Apache License, Version 2.0                  |
| Build:          | CocoaPods                                    |
| Languague:      | Swift 4                                      |
| Documentation:  | http://aerogear.org/ios/                     |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS        |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))                            |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))                              |

## Table of Content

* [Features](#features)
* [Installation](#installation)
  * [CocoaPods](#cocoapods)
* [Usage](#usage)
  * [Push registration (Programmatically)](#push-registration-programmatically)
  * [Push registration (plist)](#push-registration-plist)
  * [Push analytics](#push-analytics)
    * [Metrics when app is launched](#metrics-when-app-is-launched)
    * [Metrics when the app is brought from background to foreground](#metrics-when-the-app-is-brought-from-background-to-foreground)
* [Documentation](#documentation)
* [Demo apps](#demo-apps)
* [Development](#development)
* [Questions?](#questions)
* [Found a bug?](#found-a-bug)

## Features

* Register (Programmatically and plist) on [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unifiedpush-server/)
* Send metrics to [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unifiedpush-server/)

## Installation

### CocoaPods

In your `Podfile` add:

```bash
pod 'AeroGearPush-Swift'
```

and then:

```bash
pod install
```

to install your dependencies

## Usage

### Push registration (Programmatically)

```swift
// setup registration
let registration = DeviceRegistration(serverURL: URL(string: "<#AeroGear UnifiedPush Server URL#>")!)

// attempt to register
registration.register(
        clientInfo: { (clientDevice: ClientDeviceInformation!) in
            // setup configuration
            clientDevice.deviceToken = deviceToken
            clientDevice.variantID = "<# Variant Id #>"
            clientDevice.variantSecret = "<# Variant Secret #>"

            // apply the token, to identify THIS device
            let currentDevice = UIDevice()

            // -- optional config --
            // set some 'useful' hardware information params
            clientDevice.operatingSystem = currentDevice.systemName
            clientDevice.osVersion = currentDevice.systemVersion
            clientDevice.deviceType = currentDevice.model
        },
        success: {
            print("UnifiedPush Server registration succeeded")
        },
        failure: { (error: Error!) in
            print("failed to register, error: \(error.localizedDescription)")
        }
)
```

### Push registration (plist)

```swift
// setup registration
let registration = DeviceRegistration(config: "pushconfig")

// attempt to register
registration.register(
        clientInfo: { (clientDevice: ClientDeviceInformation!) in
            // setup configuration
            clientDevice.deviceToken = deviceToken

            // apply the token, to identify THIS device
            let currentDevice = UIDevice()

            // set some 'useful' hardware information params
            clientDevice.operatingSystem = currentDevice.systemName
            clientDevice.osVersion = currentDevice.systemVersion
            clientDevice.deviceType = currentDevice.model
        },
        success: {
            print("UnifiedPush Server registration succeeded")
        },
        failure: { (error: Error!) in
            print("failed to register, error: \(error.localizedDescription)")
        }
)
```

In your application, create a `pushconfig.plist` file, and add the following properties:

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

> NOTE: If your UPS server installation uses a `self-signed certificate`, you can find a quick solution on how to enable support on our [troubleshooting page](https://aerogear.org/docs/unifiedpush/aerogear-push-ios/troubleshooting/#_question_failure_to_connect_when_server_uses_a_self_signed_certificate), as well as links for further information on how to properly enable it on your iOS production applications.

### Push analytics

If you are interested in monitoring how a push message relates to the usage of your app, you can use metrics. Those metrics are displayed in the AeroGear UnifiedPush Server's console.

#### Metrics when app is launched

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // Send metrics when app is launched due to push notification
    PushAnalytics.sendMetricsWhenAppLaunched(launchOptions: launchOptions)

    return true
}
```

#### Metrics when the app is brought from background to foreground

```swift
func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    // Send metrics when app is launched due to push notification
    PushAnalytics.sendMetricsWhenAppAwoken(applicationState: application.applicationState, userInfo: userInfo)

    // ... Some stuffs ...

    // No additional data to fetch
    fetchCompletionHandler(UIBackgroundFetchResult.noData)

}
```

## Documentation

For more details about that please consult [our documentation](http://aerogear.org/ios/).

## Demo apps

Take a look in our demo apps:

* [UnifiedPushHelloWorld](https://github.com/aerogear/aerogear-ios-cookbook/tree/master/UnifiedPushHelloWorld)
* [Howdy](https://github.com/aerogear/aerogear-ios-cookbook/tree/master/Howdy)

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
