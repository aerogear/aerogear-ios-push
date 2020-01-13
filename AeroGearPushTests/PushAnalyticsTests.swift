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

class PushAnalyticsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "variantID")
        UserDefaults.standard.removeObject(forKey: "variantSecret")
        UserDefaults.standard.removeObject(forKey: "serverURL")
        UserDefaults.resetStandardUserDefaults()
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "variantID")
        UserDefaults.standard.removeObject(forKey: "variantSecret")
        UserDefaults.standard.removeObject(forKey: "serverURL")
        UserDefaults.resetStandardUserDefaults()
        OHHTTPStubs.removeAllStubs()
    }
 
    func testSendMetricsShouldWork() {
        UserDefaults.standard.setValue("VARIANT", forKey: "variantID")
        UserDefaults.standard.setValue("SECRET", forKey: "variantSecret")
        UserDefaults.standard.setValue("http://server.com", forKey: "serverURL")
        
        // set up http stub
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
            }, withStubResponse:( { (request: URLRequest!) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(data:Data(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        // async test expectation
        let sendMetricsExpectation = expectation(description: "Send Metrics");
        
        var options: [AnyHashable: Any] = [:]
        options[UIApplication.LaunchOptionsKey.remoteNotification] = ["aerogear-push-id":"123456"]
        // attemp to register
        PushAnalytics.sendMetricsWhenAppLaunched(launchOptions: options) { (error) -> Void in
            assert(error == nil, "Metrics sent without error")
            sendMetricsExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSendMetricsShouldFail() {
        // set up http stub
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
            }, withStubResponse:( { (request: URLRequest!) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(data:Data(), statusCode: 200, headers: ["Content-Type" : "text/json"])
            }))
        
        // async test expectation
        let sendMetricsExpectation = expectation(description: "Send Metrics");
        
        // setup registration
        _ = DeviceRegistration(serverURL: URL(string: "http://server.com")!)
        
        var options: [AnyHashable: Any] = [:]
        options[UIApplication.LaunchOptionsKey.remoteNotification] = ["aerogear-push-id":"123456"]
        
        // attemp to register
        PushAnalytics.sendMetricsWhenAppLaunched(launchOptions: options) { (error) -> Void in
            assert(error != nil, "Registration should happen before sending metrics")
            sendMetricsExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
