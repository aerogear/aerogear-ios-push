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
 * Internal implementation of the ClientDeviceInformation protocol
 */
class ClientDeviceInformationImpl: NSObject, ClientDeviceInformation {

    var deviceToken: Data?
    var variantID: String?
    var variantSecret: String?
    var alias: String?
    var categories: [String]?
    var operatingSystem: String?
    var osVersion: String?
    var deviceType: String?
 
    override init() {
        super.init()        
    }

    @objc func extractValues() -> [String: AnyObject] {
        var jsonObject =  [String: AnyObject]()
        
        jsonObject["deviceToken"] = convertToString(deviceToken) as AnyObject?
        jsonObject["alias"] = alias as AnyObject?
        jsonObject["categories"] = categories as AnyObject?
        jsonObject["operatingSystem"] = operatingSystem as AnyObject?
        jsonObject["osVersion"] = osVersion as AnyObject?
        jsonObject["deviceType"] = deviceType as AnyObject?

        return jsonObject;
    }

    // Helper to transform the Data-based token into a (useful) String:
    fileprivate func convertToString(_ deviceToken: Data?) -> String? {
        if let token = (deviceToken as NSData?)?.description {
            return token.replacingOccurrences(of: "<", with: "")
                .replacingOccurrences(of: ">", with: "")
                .replacingOccurrences(of: " ", with: "")
        }
        
        return nil
    }

}
