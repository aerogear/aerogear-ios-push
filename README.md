# aerogear-push-ios-registration [![Build Status](https://travis-ci.org/aerogear/aerogear-push-ios-registration.png)](https://travis-ci.org/aerogear/aerogear-push-ios-registration)

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server**

A small and handy library that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).


## Example Usage
```objective-c
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
      NSLog(@"PushEE registration worked");
	} failure:^(NSError *error) {
      NSLog(@"PushEE registration Error: %@", error);
  }];
}
```

## AeroGear UnifiedPush Server

For more information checkout our [tutorial](http://aerogear.org/docs/guides/aerogear-push-ios/).
