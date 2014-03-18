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

#import "AGClientDeviceInformationImpl.h"

// global NSError 'error' domain name
NSString * const AGPushErrorDomain = @"AGPushErrorDomain";


// will hold the shared instance of the AGDeviceRegistration
static AGDeviceRegistration* sharedInstance;

@interface AGDeviceRegistration() <NSURLSessionTaskDelegate>
@end

@implementation AGDeviceRegistration {
    NSURL *_baseURL;
    NSURLSession *_session;
}

-(id) initWithServerURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _baseURL = url;
        
        // initialize session
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        sessionConfig.HTTPCookieStorage = nil;
        
        // add default headers..
        [sessionConfig setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json"}];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
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
    
    // set up our request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[_baseURL URLByAppendingPathComponent:@"rest/registry/device"]];
    [request setHTTPMethod:@"POST"];
    
    // apply HTTP Basic:
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", clientInfoObject.variantID, clientInfoObject.variantSecret];
    
    
    [request setValue:[NSString stringWithFormat:@"Basic %@",
                       [[basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]]
                       forHTTPHeaderField:@"Authdrization"];
    
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[clientInfoObject extractValues] options:0 error:nil];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success)
                success();
        }
    }];
    
    [task resume];
}

+ (AGDeviceRegistration*) sharedInstance {
    return sharedInstance;
}

#pragma mark - private util section


// Transforms given String into NSError.
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

#pragma mark - NSURLSessionTask delegate

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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    NSURLRequest *newRequest = request;
    
    if (redirectResponse) {
        newRequest = nil;
    }
    completionHandler(request);
}

@end
