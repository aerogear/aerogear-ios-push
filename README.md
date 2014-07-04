# aerogear-push-ios-registration-swift (work-in-progress)

**iOS Push Notification Registration SDK for the AeroGear UnifiedPush Server (in Swift)**

A small and handy library that helps to register iOS applications with the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unified-push-server).

## Example Usage

```swift
// setup registration
let registration = AGDeviceRegistration(serverURL: NSURL(string: "<URL of the running AeroGear UnifiedPush Server>"))

// attemp to register
registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) -> () in

    clientInfo.deviceToken = <Device Token>
    clientInfo.variantID = "<Variant_id>"
    clientInfo.variantSecret = "<Variant_Secret>"

    // apply the token, to identify THIS device
    let currentDevice = UIDevice()

    // --optional config--
    // set some 'useful' hardware information params
    clientInfo.operatingSystem = currentDevice.systemName
    clientInfo.osVersion = currentDevice.systemVersion
    clientInfo.deviceType = currentDevice.model
    clientInfo.alias = "swift"
},

success: {() -> () in
    println("successfully registered!")
},

failure: {(error: NSError!) -> () in
    println("an error occured during registration: \(error.description)")
})```

