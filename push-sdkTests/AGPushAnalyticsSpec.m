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


#import "AGPushAnalytics.h"


SPEC_BEGIN(AGPushAnalyticsSpec)


describe(@"AGPushAnalytics", ^{
    
    context(@"send metrics...", ^{
        
        
        it(@"successfully", ^{
            [[NSUserDefaults standardUserDefaults] setValue:@"VARIANT" forKey:@"variantID"];
            [[NSUserDefaults standardUserDefaults] setValue:@"SECRET" forKey:@"variantSecret"];
            [[NSUserDefaults standardUserDefaults] setValue:@"http://server.com" forKey:@"serverURL"];
            
            // install the mock:
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {

                    return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                       statusCode:200
                                                          headers:@{@"Content-Type":@"text/json]"}] responseTime:0];

            }];
            NSDictionary* options = @{UIApplicationLaunchOptionsRemoteNotificationKey: @{@"aerogear-push-id":@"123456"} };
           
            
            [AGPushAnalytics sendMetricsWhenAppLaunched:options completionHandler:^(NSError *error) {
                [error shouldBeNil];
            }];
        });
        
        it(@"should fail to register if configuration block is not set", ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"variantID"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"variantSecret"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"serverURL"];
            
            // install the mock:
            [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
                return YES;
            } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                
                return [[OHHTTPStubsResponse responseWithData:[NSData data]
                                                   statusCode:200
                                                      headers:@{@"Content-Type":@"text/json]"}] responseTime:0];
                
            }];
            NSDictionary* options = @{UIApplicationLaunchOptionsRemoteNotificationKey: @{@"aerogear-push-id":@"123456"} };
            
            
            [AGPushAnalytics sendMetricsWhenAppLaunched:options completionHandler:^(NSError *error) {
                [error shouldNotBeNil];
            }];

        });
    });
});

SPEC_END
