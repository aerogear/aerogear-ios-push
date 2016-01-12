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

        beforeAll(^{
            registration = [[AGDeviceRegistration alloc]
                            initWithServerURL:[NSURL URLWithString:@"http://server.com"]];
        });
        
        it(@"shared instance should not be nil", ^{
            
            [[AGDeviceRegistration sharedInstance] shouldNotBeNil];
        });
        
        it(@"should fail to register if configuration block is not set", ^{
           
            [[theBlock(^{
                [registration registerWithClientInfo:nil success:nil failure:nil];
        
            }) should] raise];
        });
        
        it(@"should fail to register if 'deviceToken' is not set", ^{

            [[theBlock(^{
                [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                    // apply the desired info:
                    clientInfo.variantID = @"2c948a843e6404dd013e79d82e5a0009";
                } success:^() {
                    // nope...
                } failure:^(NSError *error) {
                    [error shouldNotBeNil];
                }];
                
            }) should] raise];
        });
        
        it(@"should fail to register if 'mobileVariantID' is not set", ^{

            [[theBlock(^{
                [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                    // apply the desired info:
                    clientInfo.deviceToken = [@"2c948a843e6404dd013e79d82e5a0009"
                                              dataUsingEncoding:NSUTF8StringEncoding];
                } success:nil failure:nil];

            }) should] raise];
        });
        
        it(@"should fail to register if 'mobileVariantSecret' is not set", ^{
            
            [[theBlock(^{
                [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                    // apply the desired info:
                    clientInfo.deviceToken =
                    [@"2c948a843e6404dd013e79d82e5a0009" dataUsingEncoding:NSUTF8StringEncoding];
                    clientInfo.variantID = @"2c948a843e6404dd013e79d82e5a0009";
                    
                 } success:nil failure:nil];
     
            }) should] raise];
        });
        
        it(@"should register to the server", ^{

            // install the mock:
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {

                return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                   statusCode:200
                                                      headers:@{@"Content-Type":@"text/json]"}] responseTime:0];
            }];

            __block BOOL succeeded;
            
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
                clientInfo.categories = @[@"football", @"sport"];
                
            } success:^() {
                succeeded = YES;
                
            } failure:^(NSError *error) {
                NSLog(@"%@", [error description]);
            }];
            
            [[expectFutureValue(theValue(succeeded)) shouldEventually] beYes];
        });
        
        it(@"should register with config file", ^{
            registration = [[AGDeviceRegistration alloc]
                            initWithFile:@"pushproperties"];
            [registration overridePushProperties:@{@"serverURL": @"http://hello.org"}];
            __block NSString* urlString;
            
            // install the mock:
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                urlString = request.URL.absoluteString;
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                
                return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                   statusCode:200
                                                      headers:@{@"Content-Type":@"text/json]"}] responseTime:0];
            }];
            
            __block BOOL succeeded;
            
            [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
                
                // apply the desired info:
                clientInfo.deviceToken = [@"2c948a843e6404dd013e79d82e5a0009"
                                          dataUsingEncoding:NSUTF8StringEncoding];
                
            } success:^() {
                succeeded = YES;
                
            } failure:^(NSError *error) {
                NSLog(@"%@", [error description]);
            }];
            
            [[expectFutureValue(theValue(succeeded)) shouldEventually] beYes];
            [[expectFutureValue(theValue(urlString)) shouldEventually] isEqual:theValue(@"http://hello.org/rest/registry/device")];
        });

        it(@"should correctly redirect", ^{

            // the 'fictitious' redirect url
            NSURL *redirectURL = [NSURL URLWithString:@"http://redirect.to/rest/registry/device"];

            // install the mock:
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                if ([request.URL.absoluteString isEqual:@"http://server.com/rest/registry/device"]) { // perform redirection
                    // setup 'redirect' headers
                    NSDictionary *headers = @{@"Location" : redirectURL.absoluteString};
                    return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                       statusCode:311 // redirect
                                                          headers:headers] responseTime:0];
                } else {
                    return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                       statusCode:200
                                                          headers:@{@"Content-Type":@"text/json]"}] responseTime:0];
                }
            }];

            __block BOOL succeeded;

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
                clientInfo.categories = @[@"football", @"sport"];

            } success:^() {
                succeeded = YES;

            } failure:^(NSError *error) {
                NSLog(@"%@", [error description]);
            }];

            [[expectFutureValue(theValue(succeeded)) shouldEventually] beYes];
        });
    });
});

SPEC_END