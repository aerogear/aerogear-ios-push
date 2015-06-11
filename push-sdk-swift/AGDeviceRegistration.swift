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
/**
 Utility to register an iOS device with the AeroGear UnifiedPush Server.
 */
public class AGDeviceRegistration: NSObject, NSURLSessionTaskDelegate {
    
    struct AGDeviceRegistrationError {
        static let AGPushErrorDomain = "AGPushErrorDomain"
        static let AGNetworkingOperationFailingURLRequestErrorKey = "AGNetworkingOperationFailingURLRequestErrorKey"
        static let AGNetworkingOperationFailingURLResponseErrorKey = "AGNetworkingOperationFailingURLResponseErrorKey"
    }
    
    var serverURL: NSURL!
    var session: NSURLSession!
    var config: String?
    
    /**
    An initializer method to instantiate an AGDeviceRegistration object.
    
    :param: serverURL the URL of the AeroGear Push server.
    
    :returns: the AGDeviceRegistration object.
    */
    public init(serverURL: NSURL) {
        self.serverURL = serverURL;

        super.init()

        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    /**
    An initializer method to instantiate an AGDeviceRegistration object with default app plist config file.
    
    :param: config file name where to fetch AeroGear UnifiedPush server configuration.
    :returns: the AGDeviceRegistration object.
    */
    public convenience init(config: String) {
        self.init()
        self.config = config
    }
    /**
    An initializer method to instantiate an AGDeviceRegistration object.
    
    :returns: the AGDeviceRegistration object.
    */
    public override init() {
        super.init()
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    /**
    Registers your mobile device to the AeroGear UnifiedPush server so it can start receiving messages.
    Registration information can be provided within clientInfo block or by providing a plist file
    containing the require registration information as below:
     <plist version="1.0">
        <dict>
         <key>serverURL</key>
         <string>pushServerURL e.g http(s)//host:port/context</string>
         <key>variantID</key>
         <string>variantID e.g. 1234456-234320</string>
         <key>variantSecret</key>
         <string>variantSecret e.g. 1234456-234320</string>
         ...
       </dict>
      </plist>
    
    :param: clientInfo A block object which passes in an implementation of the AGClientDeviceInformation protocol that
    holds configuration metadata that would be posted to the server during the registration process.
    
    :param: success A block object to be executed when the registration operation finishes successfully.
    This block has no return value.
    
    :param: failure A block object to be executed when the registration operation finishes unsuccessfully.
    This block has no return value and takes one argument: The `NSError` object describing
    the error that occurred during the registration process.
    */
    public func registerWithClientInfo(clientInfo: ((config: AGClientDeviceInformation) -> Void)!,
        success:(() -> Void)!, failure:((NSError) -> Void)!) -> Void {
            
            // can't proceed with no configuration block set
            assert(clientInfo != nil, "configuration block not set")

            let clientInfoObject = AGClientDeviceInformationImpl()
        
            clientInfo(config: clientInfoObject)
            
            // Check if config is available in plist file
            if clientInfoObject.variantID == nil && self.configValueForKey("variantID") != nil {
                clientInfoObject.variantID = self.configValueForKey("variantID")
            }
            
            if clientInfoObject.variantSecret == nil && self.configValueForKey("variantSecret") != nil {
                clientInfoObject.variantSecret = self.configValueForKey("variantSecret")
            }
            
            if self.serverURL?.absoluteString == nil && self.configValueForKey("serverURL") != nil {
                if let urlString = self.configValueForKey("serverURL"), let url = NSURL(string: urlString) {
                    self.serverURL = url
                } else {
                    assert(self.serverURL.absoluteString != nil, "'serverURL' should be set")
                }
            }
            
            // Fail if not all config mandatory items are present
            assert(clientInfoObject.deviceToken != nil, "'token' should be set")
            assert(clientInfoObject.variantID != nil, "'variantID' should be set")
            assert(clientInfoObject.variantSecret != nil, "'variantSecret' should be set");
            
            // locally stored information (used for metrics)
            NSUserDefaults.standardUserDefaults().setObject(clientInfoObject.variantID, forKey: "variantID")
            NSUserDefaults.standardUserDefaults().setObject(clientInfoObject.variantSecret, forKey: "variantSecret")
            NSUserDefaults.standardUserDefaults().setObject(self.serverURL.absoluteString, forKey: "serverURL")
            
            // set up our request
            let request = NSMutableURLRequest(URL: serverURL.URLByAppendingPathComponent("rest/registry/device"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "POST"
            
            // apply HTTP Basic
            let basicAuthCredentials: NSData! = "\(clientInfoObject.variantID!):\(clientInfoObject.variantSecret!)".dataUsingEncoding(NSUTF8StringEncoding)
            let base64Encoded = basicAuthCredentials.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            
            request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
            
            // serialize request
            let postData = NSJSONSerialization.dataWithJSONObject(clientInfoObject.extractValues(), options:nil, error: nil)
            
            request.HTTPBody = postData
            
            let task = session.dataTaskWithRequest(request) {(data, response, error) in
                    if error != nil {
                        failure(error)
                        return
                    }
                    
                    // verity HTTP status
                    let httpResp = response as! NSHTTPURLResponse

                    // did we succeed?
                    if httpResp.statusCode == 200 {
                        success()

                    } else { // nope, client request error (e.g. 401 /* Unauthorized */)
                        let userInfo = [NSLocalizedDescriptionKey : NSHTTPURLResponse.localizedStringForStatusCode(httpResp.statusCode),
                            AGDeviceRegistrationError.AGNetworkingOperationFailingURLRequestErrorKey: request,
                            AGDeviceRegistrationError.AGNetworkingOperationFailingURLResponseErrorKey: response];
                        
                        let error = NSError(domain:AGDeviceRegistrationError.AGPushErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)

                        failure(error)
                    }
            }
            
            task.resume()
    }
    
    /**
    We need to cater for possible redirection
    NOTE:
          As per Apple doc, the passed req is 'the proposed redirected request'. But we cannot return it as it is. The reason is,
          user-agents (and in our case NSURLconnection) 'erroneous' after a 302-redirection modify the request's http method
          and sets it to GET if the client initially performed a POST (as we do here).
    
          See  RFC 2616 (section 10.3.3) http://www.ietf.org/rfc/rfc2616.txt
          and related blog: http://tewha.net/2012/05/handling-302303-redirects/
    
          We need to 'override' that 'default' behaviour to return the original attempted NSURLRequest
          with the URL parameter updated to point to the new 'Location' header.
    */
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection redirectResponse: NSHTTPURLResponse, newRequest redirectReq: NSURLRequest, completionHandler: ((NSURLRequest!) -> Void)) {
        
        var request = redirectReq;

        // we need to redirect
        // update URL of the original request
        // to the 'new' redirected one
        var origRequest = task.originalRequest.mutableCopy() as! NSMutableURLRequest
        origRequest.URL = redirectReq.URL
        request = origRequest
        
        completionHandler(request)
    }

    
    private func configValueForKey(key: String) -> String? {
        var value: String?
        if let config = self.config { // specified plist config file
            let path = NSBundle(forClass: AGDeviceRegistration.self).pathForResource(config, ofType:"plist")
            var properties = NSMutableDictionary(contentsOfFile: path!)
            if let properties = properties {
                value = properties[key as String] as? String
            }
        } else {
            value = NSBundle.mainBundle().objectForInfoDictionaryKey(key) as? String
        }
        if (value == nil && value!.isEmpty)  {
            return nil
        } else {
            return value
        }
    }
}
