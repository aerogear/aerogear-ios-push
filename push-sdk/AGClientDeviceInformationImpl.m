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

#import "AGClientDeviceInformationImpl.h"

@interface AGClientDeviceInformationImpl()
    - (NSString *) convertToNSString:(NSData *)deviceToken;
@end

@implementation AGClientDeviceInformationImpl

// "push" related fields
@synthesize deviceToken = _deviceToken;
@synthesize mobileVariantID = _mobileVariantID;
@synthesize mobileVariantSecret = _mobileVariantSecret;
@synthesize alias = _alias;
@synthesize category = _category;

// "sysinfo" metadata fields
@synthesize operatingSystem = _operatingSystem;
@synthesize osVersion = _osVersion;
@synthesize deviceType = _deviceType;

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

-(NSDictionary *) extractValues {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    [values setValue:[self convertToNSString:_deviceToken] forKey:@"deviceToken"];
    [values setValue:_alias forKey:@"alias"];
    [values setValue:_category forKey:@"category"];

    [values setValue:_operatingSystem forKey:@"mobileOperatingSystem"];
    [values setValue:_osVersion forKey:@"osVersion"];
    [values setValue:_deviceType forKey:@"deviceType"];
    
    return values;
}

// little helper to transform the NSData-based token into a (useful) String:
- (NSString *) convertToNSString:(NSData *)deviceToken {
    NSString *tokenStr = [deviceToken description];
    NSString *pushToken = [[[tokenStr
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pushToken;
}

@end
