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

#import "AGDeviceRegistration.h"
#import "AGRegistrationHttpClient.h"

#import "AGClientDeviceInformationImpl.h"

@implementation AGDeviceRegistration {
    AGRegistrationHttpClient *_client;
}

-(id) initWithServerURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _client = [AGRegistrationHttpClient sharedInstanceWithURL:url];
        _client.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

-(void)registerWithClientInfo:(void (^)(id<AGClientDeviceInformation>))clientInfo success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    // default impl:
    AGClientDeviceInformationImpl *clientInfoObject = [[AGClientDeviceInformationImpl alloc] init];
    
    if (clientInfo) {
        // pass the object in:
        clientInfo(clientInfoObject);
    } else {
        // throw Exception!
    }
    
    // Extract the data as NSDic:
    NSDictionary *mobileVariantInstanceData = [clientInfoObject extractValues];
    // TODO: check if required values are missing...



    // add the variant ID:
    [_client setDefaultHeader:@"ag-mobile-variant" value:clientInfoObject.mobileVariantID];
    
    // POST the data to the server:
    [_client postPath:@"rest/registry/device" parameters:mobileVariantInstanceData
      success:^(AFHTTPRequestOperation *operation, id responseObject) {

         if (success) {
             success(responseObject);
         }
         
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure) {
            failure(error);
        }

    }];
    
    
}

@end
