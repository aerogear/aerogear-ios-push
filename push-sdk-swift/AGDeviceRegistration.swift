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
open class AGDeviceRegistration: NSObject, URLSessionTaskDelegate {
    
    struct AGDeviceRegistrationError {
        static let AGPushErrorDomain = "AGPushErrorDomain"
        static let AGNetworkingOperationFailingURLRequestErrorKey = "AGNetworkingOperationFailingURLRequestErrorKey"
        static let AGNetworkingOperationFailingURLResponseErrorKey = "AGNetworkingOperationFailingURLResponseErrorKey"
    }
    
    var serverURL: URL!
    var session: Foundation.URLSession!
    var config: String?
    var overrrideProperties: [String: String]?
    
    /**
    An initializer method to instantiate an AGDeviceRegistration object.
    
    :param: serverURL the URL of the AeroGear Push server.
    
    :returns: the AGDeviceRegistration object.
    */
    public init(serverURL: URL) {
        self.serverURL = serverURL;

        super.init()

        let sessionConfig = URLSessionConfiguration.default
        self.session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
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
        let sessionConfig = URLSessionConfiguration.default
        self.session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    open func overridePushProperties(_ pushProperties: [String: String]) {
        overrrideProperties = pushProperties;
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
    open func registerWithClientInfo(_ clientInfo: ((_ config: AGClientDeviceInformation) -> Void)!,
        success:(() -> Void)!, failure:((NSError) -> Void)!) -> Void {
            
            // can't proceed with no configuration block set
            assert(clientInfo != nil, "configuration block not set")

            let clientInfoObject = AGClientDeviceInformationImpl()
        
            clientInfo(clientInfoObject)
            
            // Check if config is available in plist file
            if clientInfoObject.variantID == nil && self.configValueForKey("variantID") != nil {
                clientInfoObject.variantID = self.configValueForKey("variantID")
            }
            
            if clientInfoObject.variantSecret == nil && self.configValueForKey("variantSecret") != nil {
                clientInfoObject.variantSecret = self.configValueForKey("variantSecret")
            }
            
            if self.serverURL?.absoluteString == nil && self.configValueForKey("serverURL") != nil {
                if let urlString = self.configValueForKey("serverURL"), let url = URL(string: urlString) {
                    self.serverURL = url
                } else {
                    assert(self.serverURL?.absoluteString != nil, "'serverURL' should be set")
                }
            }
            
            // deviceToken could be nil then retrieved it from local storage (from previous register).
            // This is the use case when you update categories.
            if clientInfoObject.deviceToken == nil {
                clientInfoObject.deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? Data
            }
            
            // Fail if not all config mandatory items are present
            assert(clientInfoObject.deviceToken != nil, "'token' should be set")
            assert(clientInfoObject.variantID != nil, "'variantID' should be set")
            assert(clientInfoObject.variantSecret != nil, "'variantSecret' should be set");
            
            // locally stored information (used for metrics)
            UserDefaults.standard.set(clientInfoObject.deviceToken, forKey: "deviceToken")
            UserDefaults.standard.set(clientInfoObject.variantID, forKey: "variantID")
            UserDefaults.standard.set(clientInfoObject.variantSecret, forKey: "variantSecret")
            UserDefaults.standard.set(self.serverURL.absoluteString, forKey: "serverURL")
            
            // set up our request
            var request = URLRequest(url: serverURL.appendingPathComponent("rest/registry/device"))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            // apply HTTP Basic
            let basicAuthCredentials: Data! = "\(clientInfoObject.variantID!):\(clientInfoObject.variantSecret!)".data(using: String.Encoding.utf8)
            let base64Encoded = basicAuthCredentials.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            request.setValue("Basic \(base64Encoded)", forHTTPHeaderField: "Authorization")
            
            // serialize request
            let postData: Data?
            do {
                postData = try JSONSerialization.data(withJSONObject: clientInfoObject.extractValues(), options:[])
            } catch _ {
                postData = nil
            }
            
            request.httpBody = postData
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                    if error != nil {
                        failure(error as NSError!)
                        return
                    }
                
                    // verity HTTP status
                    let httpResp = response as! HTTPURLResponse

                    // did we succeed?
                    if httpResp.statusCode == 200 {
                        success()

                    } else { // nope, client request error (e.g. 401 /* Unauthorized */)
                        let userInfo = [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResp.statusCode),
                            AGDeviceRegistrationError.AGNetworkingOperationFailingURLRequestErrorKey: request,
                            AGDeviceRegistrationError.AGNetworkingOperationFailingURLResponseErrorKey: response!] as [String : Any];
                        
                        let error = NSError(domain:AGDeviceRegistrationError.AGPushErrorDomain, code: NSURLErrorBadServerResponse, userInfo: userInfo)

                        failure(error)
                    }
            }) 
            
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
    open func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection redirectResponse: HTTPURLResponse, newRequest redirectReq: URLRequest, completionHandler: (@escaping (URLRequest?) -> Void)) {
        
        var request = redirectReq;

        // we need to redirect
        // update URL of the original request
        // to the 'new' redirected one
        let origRequest = (task.originalRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        origRequest.url = redirectReq.url
        request = origRequest as URLRequest
        
        completionHandler(request)
    }

    
    fileprivate func configValueForKey(_ key: String) -> String? {
        var value: String?
        if let overrideProperties = self.overrrideProperties, let serverURLPropertie = overrideProperties[key] {
            value = serverURLPropertie
        } else if let config = self.config { // specified plist config file
            let path = Bundle.main.path(forResource: config, ofType: "plist")
            let properties = NSMutableDictionary(contentsOfFile: path!)
            if let properties = properties {
                value = properties[key as String] as? String
            }
        } else {
            value = Bundle.main.object(forInfoDictionaryKey: key) as? String
        }
        if (value == nil && value!.isEmpty)  {
            return nil
        } else {
            return value
        }
    }
}
