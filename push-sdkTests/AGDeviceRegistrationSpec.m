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

#import <Kiwi/Kiwi.h>
#import "OHHTTPStubs.h"
#import "OHHTTPStubsResponse.h"


#import "AGDeviceRegistration.h"

SPEC_BEGIN(AGDeviceRegistrationSpec)


describe(@"AGDeviceRegistration", ^{
    
    context(@"when created.....", ^{
        
        __block AGDeviceRegistration *registration;
        __block BOOL runLoop;
        
        beforeEach(^{
            
            // install the mock:
            [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse*(NSURLRequest *request, BOOL onlyCheck) {
                return [OHHTTPStubsResponse responseWithFile:@"response.json" contentType:@"text/json" responseTime:1.0];
            }];
            
            
            registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:@"http://localhost:8080/ag-push/"]];
            runLoop = NO;
        });

        it(@"", ^{
            
            
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                
                // apply the desired info:
                clientInfo.token = @"8ecda0fe6d8e135cd97485a395338c1a9f4de5ee5f5fe2847d8161398e978d11";
                clientInfo.mobileVariantID = @"2c948a843e6404dd013e79d82e5a0009";
                clientInfo.deviceType = @"iPhone";
                clientInfo.operatingSystem = @"iOS";
                clientInfo.osVersion = @"6.1.3";
                clientInfo.alias = @"mister@xyz.com";
               
            } success:^(id responseObject) {
                runLoop = YES;
                NSLog(@"\n%@", responseObject);
               
            } failure:^(NSError *error) {
                NSLog(@"\nERROR");
               
            }];
            
            
            while(!runLoop) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
        });
       
    });
    
});


SPEC_END