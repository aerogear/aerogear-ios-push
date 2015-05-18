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

#import "AGPushAnalytics.h"

NSString * const AGPushAnalyticsErrorDomain = @"AGPushErrorDomain";
NSString * const AGPushAnalyticsNetworkingOperationFailingURLRequestErrorKey = @"AGPushAnalyticsNetworkingOperationFailingURLRequestErrorKey";
NSString * const AGPushAnalyticsNetworkingOperationFailingURLResponseErrorKey = @"AGPushAnalyticsNetworkingOperationFailingURLResponseErrorKey";


@implementation AGPushAnalytics

+ (void) sendMetricsWhenAppLaunched:(NSDictionary *)launchOptions
                  completionHandler:(void (^)(NSError *error))handler {
    if (launchOptions) {
        if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][@"aerogear-push-id"]) {
                [AGPushAnalytics sendMetricsWithMessageId:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey][@"aerogear-push-id"] completionHandler:handler];
            }
        }
    }
}

+ (void) sendMetricsWhenAppLaunched:(NSDictionary *)launchOptions {
    [AGPushAnalytics sendMetricsWhenAppLaunched:launchOptions completionHandler:nil];
}

+ (void) sendMetricsWhenAppAwoken:(UIApplicationState) applicationState
                         userInfo:(NSDictionary *)userInfo
                completionHandler:(void (^)(NSError *error))handler {
    if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground ) {
        if (userInfo[@"aerogear-push-id"]) {
            [AGPushAnalytics sendMetricsWithMessageId:userInfo[@"aerogear-push-id"] completionHandler:handler];
        }
    }
}

+ (void) sendMetricsWhenAppAwoken:(UIApplicationState) applicationState
                         userInfo:(NSDictionary *)userInfo {
    [AGPushAnalytics sendMetricsWhenAppAwoken:applicationState userInfo:userInfo completionHandler:nil];

}

+ (void) sendMetricsWithMessageId:(NSString *) messageId
                completionHandler:(void (^)(NSError *error))handler {
    NSString* variantId = [[NSUserDefaults standardUserDefaults] valueForKey:@"variantID"];
    NSString* variantSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"variantSecret"];
    NSString* urlString = [[NSUserDefaults standardUserDefaults] valueForKey:@"serverURL"];
    
    if (variantId != nil && variantSecret != nil && urlString != nil) {
        NSURL* serverURL = [[NSURL alloc] initWithString:urlString];
        // set up our request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[serverURL URLByAppendingPathComponent: [NSString stringWithFormat:@"rest/registry/device/pushMessage/%@", messageId]]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"PUT"];
        
        // apply HTTP Basic:
        NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", variantId, variantSecret];
        [request setValue:[NSString stringWithFormat:@"Basic %@",
                           [[basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]]
       forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        
        // attempt to register
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                if (httpResp.statusCode == 200) {
                    if (handler) {
                        handler(nil);
                    }
                    
                } else { // bad response (e.g. 401)
                    if (handler) {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:httpResp.statusCode] forKey:NSLocalizedDescriptionKey];
                        [userInfo setValue:request forKey:AGPushAnalyticsNetworkingOperationFailingURLRequestErrorKey];
                        [userInfo setValue:response forKey:AGPushAnalyticsNetworkingOperationFailingURLResponseErrorKey];
                        
                        error = [[NSError alloc] initWithDomain:AGPushAnalyticsErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
                        handler(error);
                    }
                }
                
            } else { // an error has occured
                if (handler) {
                    handler(error);
                }
            }
        }];
        
        [task resume];
    } else {
        if (handler) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:@"Registration should be done prior to metrics collection" forKey:NSLocalizedDescriptionKey];
            NSError* error = [[NSError alloc] initWithDomain:AGPushAnalyticsErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            handler(error);
        }
    }
}
@end
