/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import XCTest
import UIKit
import AeroGearPush

class AGDeviceRegistrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegistrationWithServerShouldWork() {
        
        // async test expectation
        let registrationExpectation = expectationWithDescription("UPS registration");
        
        // setup registration
        let registration = AGDeviceRegistration(serverURL: NSURL(string: "<# URL of the running AeroGear UnifiedPush Server #>"))
        
        // attemp to register
        registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) -> () in

            // setup configuration
            clientInfo.deviceToken = "token".dataUsingEncoding(NSUTF8StringEncoding) // dummy token
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
            
            success: {() -> () in
                registrationExpectation.fulfill()
            },
            
            failure: {(error: NSError!) -> () in
                XCTAssertTrue(false, "should have register")
                
                registrationExpectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(10, handler: {(error: NSError!) -> () in
        })
    }
}
