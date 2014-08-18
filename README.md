# aerogear-ios-push [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-push.png)](https://travis-ci.org/aerogear/aerogear-ios-push)

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

## Building the library

To build the library simply run the build script:

    build.sh

The build script will generate a buid folder containing an universal static lib and a framework, sources and documentation are also packaged.

**NOTE** on 64 bits architecture: From Xcode 5.1 release inwards, Apple changes the "Standard Architectures" to also include the arm64 architecture. See "Building" section on the [Xcode 5.1 release notes](https://developer.apple.com/library/mac/releasenotes/DeveloperTools/RN-Xcode/xc5_release_notes/xc5_release_notes.html#//apple_ref/doc/uid/TP40001051-CH2-SW2). When building with Xcode 5.0, the built library will not support 64 bits architecture. **We recommend you to build with Xcode 5.1+**


## Adding the library to your project 

You have different options to add aerogear-push-registration library to your project.

### Approach 1: use CocoaPods 

The library is available on [CocoaPods](http://cocoapods.org/?q=aerogear-Push), just include it in your 'Podfile':

    pod 'AeroGear-Push'

**Before**, you can run the app, you need to run the following command:

    pod install

After that you just need to open the ```YourProject.xcworkspace``` file in XCode and you're all set.

### Approach 2: use static lib

* step 1: copy lib

After you have built the library (see "Building the library" section), from [aerogear-ios-push](https://github.com/aerogear/aerogear-ios-push) directory, run the copy command:

    cp -R build/AeroGearPush-iphoneuniversal/* ../<YourProjectFolder>

* step 2: header search

Go to <YourProject> root node in the project navigator, and select the <YourProject> target. Select Build Settings, and locate the Header Search Paths setting in the list. Double click on the Header Search Paths item, and a popover will appear. Click the + button, and enter the following:

    $SOURCE_ROOT/include

* step 3: add library

Select the Build Phases tab, and expand the Link Binary With Libraries section and add **libpush-sdk-X.X.X.a**

* step 4: add linker flag

Click on the Build Settings tab, and locate the Other linker Flags setting and add **-ObjC**

**NOTE**: Please refer to the 64 bits note above. 

### Approach 3: use framework

* step 1: copy framework

After you have built the framework (see "Building the library" section), from [aerogear-ios-push](https://github.com/aerogear/aerogear-ios-push) directory, run the copy command:

    cp -R build/AeroGearPush-framework/AeroGearPush.framework ../<YourProjectFolder>

* step 2: add framework to Build Phases

Go to <YourProject> targets. In Build Phases / Link Binary With Libraries add AeroGearPush.framework

* step 3: angle bracket your import

```
#import <AeroGearPush/AeroGearPush.h>
```

You can use [aerogear-push-helloworld](https://github.com/aerogear/aerogear-push-helloworld) as an example of project using aerogear-push-ios-registration as a framework dependency.

**NOTE**: Please refer to the 64 bits note above. 

## Example Usage

```
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

  AGDeviceRegistration *registration = 
    [[AGDeviceRegistration alloc] initWithServerURL:
	   [NSURL URLWithString:@"http://YOUR_SERVER/ag-push/"]];

  [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {

    [clientInfo setDeviceToken:deviceToken];
    [clientInfo setVariantID:@"YOUR IOS VARIANT ID"];
    [clientInfo setVariantSecret:@"YOUR IOS VARIANT SECRET"];

    // --optional config--
    UIDevice *currentDevice = [UIDevice currentDevice];
    [clientInfo setOperatingSystem:[currentDevice systemName]];
    [clientInfo setOsVersion:[currentDevice systemVersion]];
    [clientInfo setDeviceType: [currentDevice model]];
	} success:^() {
      NSLog(@"UnifiedPush Server registration worked");
	} failure:^(NSError *error) {
      NSLog(@"UnifiedPush Server registration Error: %@", error);
  }];
}
```

## Receiving Remote Notifications

There are no extra hooks for receiving notifications with the AeroGear library. You can use the existing delegate for receiving remote notifications while the application is running, like:

```
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  // extract desired value from the dictionary...
}
```

## AeroGear UnifiedPush Server

For more information checkout our [tutorial](http://aerogear.org/docs/unifiedpush/aerogear-push-ios/).
