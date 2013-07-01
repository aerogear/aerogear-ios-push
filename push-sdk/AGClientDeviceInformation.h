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

#import <Foundation/Foundation.h>

@protocol AGClientDeviceInformation <NSObject>

/**
 * The Device Token which identifies the device within APNs.
 */
@property (copy, nonatomic) NSData* deviceToken;

/**
 * The ID of the mobile Variant, for which this client will be registered.
 */
@property (copy, nonatomic) NSString* mobileVariantID;

/**
 * The mobile Variant's secret.
 */
@property (copy, nonatomic) NSString* mobileVariantSecret;

/**
 * Application specific alias to identify users with the system.
 * E.g. email address or username
 */
@property (copy, nonatomic) NSString* alias;

/**
 * A category, used for tagging/metadata
 */
@property (copy, nonatomic) NSString* category;

/**
 * The name of the underlying OS (e.g. iOS)
 */
@property (copy, nonatomic) NSString* operatingSystem;

/**
 * The version of the used OS (e.g. 6.1.3)
 */
@property (copy, nonatomic) NSString* osVersion;

/**
 * The device type (e.g. iPhone or iPod)
 */
@property (copy, nonatomic) NSString* deviceType;

@end
