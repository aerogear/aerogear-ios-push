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

import Foundation
import UIKit

/**
Utility class used to send metrics information to the AeroGear UnifiedPush Server when the app is opened due to a Push notification.
*/
public class AGPushAnalytics {
    struct AGPushAnalyticsError {
        static let AGPushAnalyticsErrorDomain = "AGPushAnalyticsErrorDomain"
        static let AGNetworkingOperationFailingURLRequestErrorKey = "AGNetworkingOperationFailingURLRequestErrorKey"
        static let AGNetworkingOperationFailingURLResponseErrorKey = "AGNetworkingOperationFailingURLResponseErrorKey"
    }
    /**
    Send metrics to the AeroGear Push server when the app is launched due to a push notification.
    
    - parameter launchOptions: contains the message id used to collect metrics.
    
    - parameter completionHandler: A block object to be executed when the send metrics operation finishes. Defaulted to no action.
    */
    class public func sendMetricsWhenAppLaunched(launchOptions: [NSObject:AnyObject]?, completionHandler: ((error: NSError? ) -> Void) = {(error: NSError?) in }) {
        if let options = launchOptions {
            if let option : NSDictionary = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                if let metrics = option["aerogear-push-id"] as? String {
                    sendMetrics(metrics, completionHandler: completionHandler)
                }
            }
        }
    }
    
    /**
    Send metrics to the AeroGear Push server when the app is brought from background to
    foreground due to a push notification.
    
    - parameter applicationState: to make sure the app was in background.
    - parameter userInfo: contains the message id used to collect metrics.
    - parameter completionHandler: A block object to be executed when the send metrics operation finishes. Defaulted to no action.
    */
    class public func sendMetricsWhenAppAwoken(applicationState: UIApplicationState, userInfo: [NSObject:AnyObject], completionHandler: ((error: NSError? ) -> Void) = {(error: NSError?) in }) {
        if applicationState == .Inactive || applicationState == .Background  {
            //opened from a push notification when the app was on background
            if let messageId = userInfo["aerogear-push-id"] as? String {
                sendMetrics(messageId, completionHandler: completionHandler)
            }
        }
    }
    
    class private func sendMetrics(messageId: String, completionHandler: ((error: NSError? ) -> Void) = {(error: NSError?) in }) {
        let variantId = NSUserDefaults.standardUserDefaults().valueForKey("variantID") as? String
        let variantSecret = NSUserDefaults.standardUserDefaults().valueForKey("variantSecret") as? String
        let urlString = NSUserDefaults.standardUserDefaults().valueForKey("serverURL") as? String
        
        
        if let variantId = variantId, let variantSecret = variantSecret, let urlString = urlString {
            let serverURL = NSURL(string: urlString)
            // set up our request
            let request = NSMutableURLRequest(URL: serverURL!.URLByAppendingPathComponent("rest/registry/device/pushMessage/\(messageId)"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "PUT"
            
            // apply HTTP Basic
            let basicAuthCredentials: NSData! = "\(variantId):\(variantSecret)".dataUsingEncoding(NSUTF8StringEncoding)
            let base64Encoded = basicAuthCredentials.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig)
            
            let task = session.dataTaskWithRequest(request) {(data, response, error) in
                if error != nil {
                    completionHandler(error: error)
                    return
                }
                
                // verity HTTP status
                let httpResp = response as! NSHTTPURLResponse
                
                // did we succeed?
                if httpResp.statusCode == 200 {
                    completionHandler(error: nil)
                    
                } else { // nope, client request error (e.g. 401 /* Unauthorized */)
                    let userInfo = [NSLocalizedDescriptionKey : NSHTTPURLResponse.localizedStringForStatusCode(httpResp.statusCode),
                        AGPushAnalyticsError.AGNetworkingOperationFailingURLRequestErrorKey: request,
                        AGPushAnalyticsError.AGNetworkingOperationFailingURLResponseErrorKey: response!];
                    
                    let error = NSError(domain:AGPushAnalyticsError.AGPushAnalyticsErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                    
                    completionHandler(error: error)
                }
            }
            
            task.resume()
        } else {
            let userInfo = [NSLocalizedDescriptionKey : "Registration should be done prior to metrics collection"];
            let error = NSError(domain:AGPushAnalyticsError.AGPushAnalyticsErrorDomain, code: 0, userInfo: userInfo)
            completionHandler(error: error)
        }
    }
}
    