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

class AGPushAnalyticsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }
 
    func testSendMetricsShouldWork() {
        NSUserDefaults.standardUserDefaults().setValue("VARIANT", forKey: "variantID")
        NSUserDefaults.standardUserDefaults().setValue("SECRET", forKey: "variantSecret")
        NSUserDefaults.standardUserDefaults().setValue("http://server.com", forKey: "serverURL")
        
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( { (request: NSURLRequest!) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(data:NSData(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        // async test expectation
        let sendMetricsExpectation = expectationWithDescription("Send Metrics");
        
        var options: [NSObject:AnyObject] = [:]
        options[UIApplicationLaunchOptionsRemoteNotificationKey] = ["aerogear-push-id":"123456"]
        // attemp to register
        AGPushAnalytics.sendMetricsWhenAppLaunched(options) { (error) -> Void in
            assert(error == nil, "Metrics sent without error")
            sendMetricsExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSendMetricsShouldFail() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("variantID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("variantSecret")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("serverURL")
        // set up http stub
        OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
            return true
            }, withStubResponse:( { (request: NSURLRequest!) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(data:NSData(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        // async test expectation
        let sendMetricsExpectation = expectationWithDescription("Send Metrics");
        
        // setup registration
        let registration = AGDeviceRegistration(serverURL: NSURL(string: "http://server.com")!)
        
        var options: [NSObject:AnyObject] = [:]
        options[UIApplicationLaunchOptionsRemoteNotificationKey] = ["aerogear-push-id":"123456"]
        
        // attemp to register
        AGPushAnalytics.sendMetricsWhenAppLaunched(options) { (error) -> Void in
            assert(error != nil, "Registration should happen before sending metrics")
            sendMetricsExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
}
