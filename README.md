# aerogear-ios-push [![Build Status](https://travis-ci.org/aerogear/aerogear-ios-push.png)](https://travis-ci.org/aerogear/aerogear-ios-push)

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | CocoaPods  |
| Documentation:  | http://aerogear.org/ios/  |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |

## Adding the library to your project

The library is available on [CocoaPods](http://cocoapods.org/?q=aerogear-Push), just include it in your 'Podfile':

    pod 'AeroGear-Push'

**Before**, you can run the app, you need to run the following command:

    pod install

After that you just need to open the `YourProject.xcworkspace` file in Xcode and you're all set.


## Example Usage
### Push registration
```ObjC
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

### Push registration with app plist
In the `AppDelegate.m` file:

```ObjC
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

  AGDeviceRegistration *registration =
    [[AGDeviceRegistration alloc] init];

  [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {

    [clientInfo setDeviceToken:deviceToken];
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
In your application info.plist, add the following properties:

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

## Receiving Remote Notifications

There are no extra hooks for receiving notifications with the AeroGear library. You can use the existing delegate for receiving remote notifications while the application is running, like:

```
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  // extract desired value from the dictionary...
}
```
### Push analytics

If you are interested in monitoring how a push message relates to the usage of your app, you can use metrics. Those emtrics are displayed in the AeroGear UnifiedPush Server's console.

* Send metrics when app is launched due to push notification

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AGPushAnalytics sendMetricsWhenAppLaunched:launchOptions];
    return YES;
}

```
* Send metrics when the app is brought from background to foreground due to a push notification

```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {    
    [AGPushAnalytics sendMetricsWhenAppAwoken:application.applicationState userInfo: userInfo];
}
```
## AeroGear UnifiedPush Server

For more information checkout our [tutorial](http://aerogear.org/docs/unifiedpush/aerogear-push-ios/).

## Documentation

For more details about the current release, please consult [our documentation](http://aerogear.org/ios/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
