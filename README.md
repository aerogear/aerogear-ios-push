# aerogear-push-ios-registration

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library written in [Swift](https://developer.apple.com/swift/) that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

## Adding the library to your project 

Follow these steps to add the library in your swift project.

1. [Clone this repository and checkout `"swift"` branch](#1-clone-this-repository)
2. [Add `AeroGearPush.xcodeproj` to your application target](#2-add-aerogearpush-xcodeproj-to-your-application-target)
3. [Link `AeroGearPush.framework` to your build settings](#3-link-aerogearpush-framework-to-your-build-settings)
4. Start writing your app!

> **NOTE:** Hopefully in the future and as the Swift language and tools around it mature, more straightforward distribution mechanisms will be employed using e.g [cocoapods](http://cocoapods.org) and framework builds. Currently neither cocoapods nor binary framework builds support Swift. For more information, consult this [mail thread](http://aerogear-dev.1069024.n5.nabble.com/aerogear-dev-Swift-Frameworks-Static-libs-and-Cocoapods-td8456.html) that describes the current situation.

### 1. Clone this repository

```
git clone git@github.com:aerogear/aerogear-ios-push.git
git checkout swift
```

### 2. Add `AeroGearPush.xcodeproj` to your application target

Right-click on the group containing your application target and select `Add Files To YourApp`

![](http://f.cl.ly/items/082h0J2u200h0Q281U15/add-framework.png)

Next, select `AeroGearPush.xcodeproj`, which you downloaded in step 1.

![](http://f.cl.ly/items/1p3X0c153F0y3h3L3f3k/add-framework-selector.png)

### 3. Link `AeroGearPush.framework` to your build settings

Link the framework during your application target's `Link Binary with Libraries` build phase.

![](http://f.cl.ly/items/032r3k0R1G3m3y2G0f09/link-framework.png)

### 4. Start writing your app!

If you run into any problems, please [file an issue](http://issues.jboss.org/browse/AEROGEAR) and join our [mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev)

## Example Usage

```swift
  func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
     // setup registration
    let registration = AGDeviceRegistration(serverURL: NSURL(string: "<# URL of the running AeroGear UnifiedPush Server #>"))
    
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

## Running tests

The project uses [AGURLSessionStubs](https://github.com/cvasilak/AGURLSessionStubs) framework for stubbing it's http network requests. Before running the tests, ensure that a copy is added in your project using `git submodule`. On the root directory of the project run:

```bash
git submodule init && git submodule update
```

You are now ready to run the tests.

## AeroGear UnifiedPush Server

For more information, checkout our [tutorial](http://aerogear.org/docs/guides/aerogear-push-ios/).
