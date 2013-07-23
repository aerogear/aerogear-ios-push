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

// global NSError 'error' domain name
NSString * const AGPushErrorDomain = @"AGPushErrorDomain";


// will hold the shared instance of the AGDeviceRegistration
static AGDeviceRegistration* sharedInstance;

@implementation AGDeviceRegistration {
    AGRegistrationHttpClient *_client;
}

-(id) initWithServerURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _client = [AGRegistrationHttpClient sharedInstanceWithURL:url];
        _client.parameterEncoding = AFJSONParameterEncoding;
        
        sharedInstance = self;
    }
    
    return self;
}

-(void)registerWithClientInfo:(void (^)(id<AGClientDeviceInformation>))clientInfo
                      success:(void (^)(void))success
                      failure:(void (^)(NSError *))failure {
    
    // default impl:
    AGClientDeviceInformationImpl *clientInfoObject = [[AGClientDeviceInformationImpl alloc] init];
    
    if (clientInfo) {
        // pass the object in:
        clientInfo(clientInfoObject);
    } else { // can't proceed with no configuration block set
        if (failure) {
            NSError *requiredArgumentsMissing =
            [self constructNSError:@"configuration block is missing"];
            
            //invoke given failure block and return:
            failure(requiredArgumentsMissing);
            return;
        }
    }
    
    // make sure 'deviceToken', 'mobileVariantID' and 'mobileVariantSecret' config params are set
    if (clientInfoObject.deviceToken == nil || clientInfoObject.variantID == nil || clientInfoObject.variantSecret == nil) {

        if (failure) {
            NSError *requiredArgumentsMissing =
              [self constructNSError:@"please ensure that 'token', 'VariantID'  and 'VariantSecret' configurations params are set"];
            
            //invoke given failure block and return:
            failure(requiredArgumentsMissing);
            return;
        }
    }
    
    // apply HTTP Basic:
    [_client setAuthorizationHeaderWithUsername:clientInfoObject.variantID password:clientInfoObject.variantSecret];
    
    // POST the data to the server:
    [_client postPath:@"rest/registry/device" parameters:[clientInfoObject extractValues]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  if (success) {
                      success();
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
                  if (failure) {
                      failure(error);
                  }
                  
              }];
}

+ (AGDeviceRegistration*) sharedInstance {
    return sharedInstance;
}

#pragma mark - private util section

/**
 * Transforms given String into NSError.
 */
-(NSError *) constructNSError:(NSString*) message {
    // build the required map:
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:message forKey:NSLocalizedDescriptionKey];

    // constrict the NSError object:
    NSError* error = [NSError errorWithDomain:AGPushErrorDomain
                                         code:0
                                     userInfo:userInfo];

    return error;
}


@end
