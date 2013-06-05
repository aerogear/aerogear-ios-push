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

@implementation AGClientDeviceInformationImpl

@synthesize token = _token;
@synthesize operatingSystem = _operatingSystem;
@synthesize osVersion = _osVersion;
@synthesize mobileVariantID = _mobileVariantID;

@synthesize deviceType = _deviceType;
@synthesize alias = _alias;
@synthesize category = _category;

- (id)init {
    self = [super init];
    if (self) {

    }
    
    return self;
}


-(NSDictionary *) extractValues {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    [values setValue:_token forKey:@"deviceToken"];
    [values setValue:_operatingSystem forKey:@"mobileOperatingSystem"];
    [values setValue:_osVersion forKey:@"osVersion"];
    [values setValue:_deviceType forKey:@"deviceType"];
    [values setValue:_alias forKey:@"alias"];
    [values setValue:_category forKey:@"category"];
    
    return values;
}

@end
