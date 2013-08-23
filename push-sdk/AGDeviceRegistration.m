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
    
    // set up our request
    NSMutableURLRequest *request = [_client requestWithMethod:@"POST"
                                                         path:@"rest/registry/device"
                                                   parameters:[clientInfoObject extractValues]];
    // set up our Operation
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if (success) {
            success();
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(error);
        }
    }];
    
    // we need to cater for possible redirection
    //
    // NOTE:
    //      As per Apple doc, the passed req is 'the proposed redirected request'. But we cannot return it as it is. The reason is,
    //      user-agents (and in our case NSURLconnection) 'erroneous' after a 302-redirection modify the request's http method
    //      and sets it to GET if the client initially performed a POST (as we do here).
    //
    //      See  RFC 2616 (section 10.3.3) http://www.ietf.org/rfc/rfc2616.txt
    //      and related blog: http://tewha.net/2012/05/handling-302303-redirects/
    //
    //      We need to 'override' that 'default' behaviour by using a 'setRedirectResponseBlock', which will return
    //      the original attempted NSURLRequest with the URL parameter updated to point to the new 'Location' header.
    //
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *redirectReq, NSURLResponse *redirectResponse) {
        
        if (redirectResponse != nil) {  // we need to redirect
            // update URL of the original request
            // to the 'new' redirected one
            request.URL = redirectReq.URL;
        }
        
        return request;
    }];
    
    // start up
    [_client enqueueHTTPRequestOperation:operation];
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
    
    // construct the NSError object:
    NSError* error = [NSError errorWithDomain:AGPushErrorDomain
                                         code:0
                                     userInfo:userInfo];
    
    return error;
}


@end
