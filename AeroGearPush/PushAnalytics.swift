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
open class PushAnalytics {
    struct PushAnalyticsError {
        static let PushAnalyticsErrorDomain = "PushAnalyticsErrorDomain"
        static let NetworkingOperationFailingURLRequestErrorKey = "NetworkingOperationFailingURLRequestErrorKey"
        static let NetworkingOperationFailingURLResponseErrorKey = "NetworkingOperationFailingURLResponseErrorKey"
    }
    /**
    Send metrics to the AeroGear Push server when the app is launched due to a push notification.
    
    :param: launchOptions contains the message id used to collect metrics.
    
    :param: completionHandler A block object to be executed when the send metrics operation finishes. Defaulted to no action.
    */
    class open func sendMetricsWhenAppLaunched(launchOptions: [AnyHashable: Any]?, completionHandler: @escaping ((_ error: NSError? ) -> Void) = {(error: NSError?) in }) {
        if let options = launchOptions {
            if let option : NSDictionary = options[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                if let metrics = option["aerogear-push-id"] as? String {
                    sendMetrics(metrics, completionHandler: completionHandler)
                }
            }
        }
    }
    
    /**
    Send metrics to the AeroGear Push server when the app is brought from background to
    foreground due to a push notification.
    
    :param: applicationState to make sure the app was in background.
    :param: userInfo contains the message id used to collect metrics.
    :param: completionHandler A block object to be executed when the send metrics operation finishes. Defaulted to no action.
    */
    class open func sendMetricsWhenAppAwoken(applicationState: UIApplicationState, userInfo: [AnyHashable: Any], completionHandler: @escaping ((_ error: NSError? ) -> Void) = {(error: NSError?) in }) {
        if applicationState == .inactive || applicationState == .background  {
            //opened from a push notification when the app was on background
            if let messageId = userInfo["aerogear-push-id"] as? String {
                sendMetrics(messageId, completionHandler: completionHandler)
            }
        }
    }
    
    class fileprivate func sendMetrics(_ messageId: String, completionHandler: @escaping ((_ error: NSError? ) -> Void) = {(error: NSError?) in }) {
        let variantId = UserDefaults.standard.value(forKey: "variantID") as? String
        let variantSecret = UserDefaults.standard.value(forKey: "variantSecret") as? String
        let urlString = UserDefaults.standard.value(forKey: "serverURL") as? String
        
        
        if let variantId = variantId, let variantSecret = variantSecret, let urlString = urlString {
            let serverURL = URL(string: urlString)
            // set up our request
            var request = URLRequest(url: serverURL!.appendingPathComponent("rest/registry/device/pushMessage/\(messageId)"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            // apply HTTP Basic
            let basicAuthCredentials: Data! = "\(variantId):\(variantSecret)".data(using: String.Encoding.utf8)
            let base64Encoded = basicAuthCredentials.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if error != nil {
                    completionHandler(error as NSError?)
                    return
                }
                
                // verity HTTP status
                let httpResp = response as! HTTPURLResponse
                
                // did we succeed?
                if httpResp.statusCode == 200 {
                    completionHandler(nil)
                    
                } else { // nope, client request error (e.g. 401 /* Unauthorized */)
                    let userInfo = [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResp.statusCode),
                        PushAnalyticsError.NetworkingOperationFailingURLRequestErrorKey: request,
                        PushAnalyticsError.NetworkingOperationFailingURLResponseErrorKey: response!] as [String : Any];
                    
                    let error = NSError(domain:PushAnalyticsError.PushAnalyticsErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
                    
                    completionHandler(error)
                }
            }) 
            
            task.resume()
        } else {
            let userInfo = [NSLocalizedDescriptionKey : "Registration should be done prior to metrics collection"];
            let error = NSError(domain:PushAnalyticsError.PushAnalyticsErrorDomain, code: 0, userInfo: userInfo)
            completionHandler(error)
        }
    }
}
