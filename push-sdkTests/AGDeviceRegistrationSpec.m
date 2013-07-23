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
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                return [OHHTTPStubsResponse responseWithData:[NSData data]
                                                  statusCode:200
                                                responseTime:1.0
                                                     headers:@{@"Content-Type":@"text/json]"}];
            }];
            
            
            registration = [[AGDeviceRegistration alloc]
                            initWithServerURL:[NSURL URLWithString:@"http://localhost:8080/ag-push/"]];
            
            runLoop = NO;
            
        });
        
        it(@"shared instance should not be nil", ^{
            
            [[AGDeviceRegistration sharedInstance] shouldNotBeNil];
        });
        
        it(@"failure block should be invoked with an NSError object if configuration block is not set", ^{
            [registration registerWithClientInfo:nil success:^() {
                // nope...
            } failure:^(NSError *error) {
                [error shouldNotBeNil];
            }
             ];
        });
        
        it(@"failure block should be invoked with an NSError object if 'deviceToken' is not set", ^{
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                // apply the desired info:
                clientInfo.variantID = @"2c948a843e6404dd013e79d82e5a0009";
            } success:^() {
                // nope...
            } failure:^(NSError *error) {
                [error shouldNotBeNil];
            }];
            
        });
        
        it(@"failure block should be invoked with an NSError object if 'mobileVariantID' is not set", ^{
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                // apply the desired info:
                clientInfo.deviceToken = [@"2c948a843e6404dd013e79d82e5a0009"
                                          dataUsingEncoding:NSUTF8StringEncoding];
            } success:^() {
                // nope...
            } failure:^(NSError *error) {
                [error shouldNotBeNil];
            }];
        });
        
        it(@"failure block should be invoked with an NSError object if 'mobileVariantSecret' is not set", ^{
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                // apply the desired info:
                clientInfo.deviceToken =
                [@"2c948a843e6404dd013e79d82e5a0009" dataUsingEncoding:NSUTF8StringEncoding];
                clientInfo.variantID = @"2c948a843e6404dd013e79d82e5a0009";
                
            } success:^() {
                // nope...
            } failure:^(NSError *error) {
                [error shouldNotBeNil];
            }];
        });
        
        it(@"should register to the server", ^{
            
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                
                // apply the desired info:
                clientInfo.deviceToken = [@"2c948a843e6404dd013e79d82e5a0009"
                                          dataUsingEncoding:NSUTF8StringEncoding];
                clientInfo.variantID = @"2c948a843e6404dd013e79d82e5a0009";
                clientInfo.variantSecret = @"secret";
                clientInfo.deviceType = @"iPhone";
                clientInfo.operatingSystem = @"iOS";
                clientInfo.osVersion = @"6.1.3";
                clientInfo.alias = @"mister@xyz.com";
                
            } success:^() {
                runLoop = YES;
            } failure:^(NSError *error) {
            }];
            
            while(!runLoop) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
        });
        
        
    });
    
});


SPEC_END