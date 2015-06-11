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

NSString * const AGPushErrorDomain = @"AGPushErrorDomain";
NSString * const AGNetworkingOperationFailingURLRequestErrorKey = @"AGNetworkingOperationFailingURLRequestErrorKey";
NSString * const AGNetworkingOperationFailingURLResponseErrorKey = @"AGNetworkingOperationFailingURLResponseErrorKey";

// will hold the shared instance of the AGDeviceRegistration
static AGDeviceRegistration* sharedInstance;

@interface AGDeviceRegistration() <NSURLSessionTaskDelegate>
@end

@implementation AGDeviceRegistration {
    NSURL *_baseURL;
    NSURLSession *_session;
    NSString* _configFile;
}

-(id) initWithServerURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _baseURL = url;
        
        // initialize session
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        sharedInstance = self;
    }
    
    return self;
}

-(id) init {
    self = [super init];
    if (self) {
        // initialize session
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        sharedInstance = self;
    }
    
    return self;
}

-(id) initWithFile:(NSString*)configFile {
    self = [super init];
    if (self) {
        // initialize session
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _configFile = configFile;
        sharedInstance = self;
    }
    
    return self;
}

-(void)registerWithClientInfo:(void (^)(id<AGClientDeviceInformation>))clientInfo
                      success:(void (^)(void))success
                      failure:(void (^)(NSError *))failure {
    
    // can't proceed with no configuration block set
    NSParameterAssert(clientInfo);
    
    // default impl:
    AGClientDeviceInformationImpl *clientInfoObject = [[AGClientDeviceInformationImpl alloc] init];
    // pass the object in:
    clientInfo(clientInfoObject);
    
    // Get config file
    
    // Check if config is available in plist file
    if (clientInfoObject.variantID == nil && [self configValueForKey:@"variantID"] != nil) {
        clientInfoObject.variantID = [self configValueForKey:@"variantID"];
    }
    
    if (clientInfoObject.variantSecret == nil && [self configValueForKey:@"variantSecret"] != nil) {
        clientInfoObject.variantSecret = [self configValueForKey:@"variantSecret"];
    }
    
    if (_baseURL == nil && [self configValueForKey:@"serverURL"] != nil) {
        NSURL* url = [[NSURL alloc] initWithString: [self configValueForKey:@"serverURL"]];
        if (url) {
            _baseURL = url;
        } else {
            NSAssert(_baseURL.absoluteString != nil, @"'serverURL' should be set");
        }
    }
    
    NSAssert(clientInfoObject.deviceToken, @"'token' should be set");
    NSAssert(clientInfoObject.variantID, @"'variantID' should be set");
    NSAssert(clientInfoObject.variantSecret, @"'variantSecret' should be set");
    
    // locally stored information
    [[NSUserDefaults standardUserDefaults] setObject: clientInfoObject.variantID forKey: @"variantID"];
    [[NSUserDefaults standardUserDefaults] setObject: clientInfoObject.variantSecret forKey: @"variantSecret"];
    [[NSUserDefaults standardUserDefaults] setObject: _baseURL.absoluteString forKey: @"serverURL"];
    
    // set up our request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[_baseURL URLByAppendingPathComponent:@"rest/registry/device"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // apply HTTP Basic:
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", clientInfoObject.variantID, clientInfoObject.variantSecret];
    [request setValue:[NSString stringWithFormat:@"Basic %@",
                       [[basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]]
   forHTTPHeaderField:@"Authorization"];
    
    // serialize request
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[clientInfoObject extractValues] options:0 error:nil];
    [request setHTTPBody:postData];
    
    // attempt to register
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                if (success) {
                    success();
                }
                
            } else { // bad response (e.g. 401)
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode] forKey:NSLocalizedDescriptionKey];
                [userInfo setValue:request forKey:AGNetworkingOperationFailingURLRequestErrorKey];
                [userInfo setValue:response forKey:AGNetworkingOperationFailingURLResponseErrorKey];
                
                error = [[NSError alloc] initWithDomain:AGPushErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
                
                if (failure) {
                    failure(error);
                }
            }
            
        } else { // an error has occured
            if (failure) {
                failure(error);
            }
        }
    }];
    
    [task resume];
}

+ (AGDeviceRegistration*) sharedInstance {
    return sharedInstance;
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
//      We need to 'override' that 'default' behaviour to return the original attempted NSURLRequest
//      with the URL parameter updated to point to the new 'Location' header.
//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse
        newRequest:(NSURLRequest *)redirectReq
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    NSURLRequest *request = redirectReq;
    
    if (redirectResponse != nil) {  // we need to redirect
        // update URL of the original request
        // to the 'new' redirected one
        NSMutableURLRequest *origRequest = [task.originalRequest mutableCopy];
        origRequest.URL = redirectReq.URL;
        
        request = origRequest;
    }
    
    completionHandler(request);
}

#pragma mark - Utility methods

- (NSString *) configValueForKey:(NSString *)key {
    NSString* value;
    if (_configFile) { // specified plist config file
        NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:_configFile ofType:@"plist"];
        NSMutableDictionary* properties = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        value = properties[key];
    } else { // default plist file
        value = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
    }
    
    if ([value length] == 0) {
        return nil;
    } else {
        return value;
    }
}

@end
