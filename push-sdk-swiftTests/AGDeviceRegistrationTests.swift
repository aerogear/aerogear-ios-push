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
import OHHTTPStubs

class AGDeviceRegistrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }

    func testRegistrationWithServerShouldWork() {
        // set up http stub
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
        }, withStubResponse:( { (request: URLRequest!) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data:Data(), statusCode: 200, headers: ["Content-Type" : "text/json"])
        }))
        
        // async test expectation
        let registrationExpectation = expectation(description: "UPS registration");
        
        // setup registration
        let registration = AGDeviceRegistration(serverURL: URL(string: "http://server.com")!)
        
        // attemp to register
        registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in

            // setup configuration
            clientInfo.deviceToken = "2c948a843e6404dd013e79d82e5a0009".data(using: String.Encoding.utf8) // dummy token
            clientInfo.variantID = "8bd6e6a3-df6b-466c-8292-ed062f2427e8"
            clientInfo.variantSecret = "1c9a6066-e0e5-4bcb-ab78-994335f59874"
            
            // apply the token, to identify THIS device
            let currentDevice = UIDevice()
            
            // --optional config--
            // set some 'useful' hardware information params
            clientInfo.operatingSystem = currentDevice.systemName
            clientInfo.osVersion = currentDevice.systemVersion
            clientInfo.deviceType = currentDevice.model
            },
            
            success: {
                registrationExpectation.fulfill()
            },
            
            failure: {(error: NSError!) in
                XCTAssertTrue(false, "should have register")
                
                registrationExpectation.fulfill()
            })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRegistrationWithServerURLOverridenShouldWork() {
        var urlString: String?
        // set up http stub
        OHHTTPStubs.stubRequests(passingTest: { request in
            urlString =  request.url?.absoluteString
            return true
            }, withStubResponse:( { (request: URLRequest!) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(data:Data(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        // async test expectation
        let registrationExpectation = expectation(description: "UPS registration");
        
        // setup registration
        let registration = AGDeviceRegistration(config: "pushproperties")
        registration.overridePushProperties(["serverURL": "http://serveroverridden.com"])
        
        // attemp to register
        registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in
            
            // setup configuration
            clientInfo.deviceToken = "2c948a843e6404dd013e79d82e5a0009".data(using: String.Encoding.utf8) // dummy token
            clientInfo.variantID = "8bd6e6a3-df6b-466c-8292-ed062f2427e8"
            clientInfo.variantSecret = "1c9a6066-e0e5-4bcb-ab78-994335f59874"
            
            // apply the token, to identify THIS device
            let currentDevice = UIDevice()
            
            // --optional config--
            // set some 'useful' hardware information params
            clientInfo.operatingSystem = currentDevice.systemName
            clientInfo.osVersion = currentDevice.systemVersion
            clientInfo.deviceType = currentDevice.model
            },
            
            success: {
                assert(urlString == "http://serveroverridden.com/rest/registry/device")
                registrationExpectation.fulfill()
            },
            
            failure: {(error: NSError!) in
                XCTAssertTrue(false, "should have register")
                
                registrationExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRedirectionAndRegistrationWithServerShouldWork() {
        // set up http stub
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
        }, withStubResponse:( { (request: URLRequest!) -> OHHTTPStubsResponse in
            if request.url!.absoluteString == "http://server.com/rest/registry/device" { // perform redirection
                let headers = ["Location": "http://redirect.to/rest/registry/device"]
                return OHHTTPStubsResponse(data:Data(), statusCode: 311, headers: headers)

            } else {
                return OHHTTPStubsResponse(data:Data(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }
        }))

        // async test expectation
        let registrationExpectation = expectation(description: "UPS registration with redirect");

        // setup registration
        let registration = AGDeviceRegistration(serverURL: URL(string: "http://server.com")!)
        
        // attemp to register
        registration.registerWithClientInfo({ (clientInfo: AGClientDeviceInformation!) in
            
            // setup configuration
            clientInfo.deviceToken = "2c948a843e6404dd013e79d82e5a0009".data(using: String.Encoding.utf8) // dummy token
            clientInfo.variantID = "8bd6e6a3-df6b-466c-8292-ed062f2427e8"
            clientInfo.variantSecret = "1c9a6066-e0e5-4bcb-ab78-994335f59874"
            
            // apply the token, to identify THIS device
            let currentDevice = UIDevice()
            
            // --optional config--
            // set some 'useful' hardware information params
            clientInfo.operatingSystem = currentDevice.systemName
            clientInfo.osVersion = currentDevice.systemVersion
            clientInfo.deviceType = currentDevice.model
            },
            
            success: {
                registrationExpectation.fulfill()
            },
            
            failure: {(error: NSError!) in
                XCTAssertTrue(false, "should have register")
                
                registrationExpectation.fulfill()
            })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
