//
// BPXLUUIDHandler.h
// UUIDHandler
//
// Created by Doug Russell on 2/29/12.
// Copyright (c) 2012 Black Pixel. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

@interface BPXLUUIDHandler : NSObject

/**
 * Retrieve UUID from keychain, if one does not exist, generate one and store it in the keychain.
 * UUIDs stored in the keychain will perisist across application installs
 * but not across device restores.
 */
+ (NSString *)UUID;
/**
 * Remove stored UUID from keychain
 */
+ (void)reset;
/**
 * Getter/setter for access group used for reading/writing from keychain.
 * Useful for shared keychain access across applications with the
 * same bundle seed (requires properly configured provisioning and entitlements)
 */
+ (NSString *)accessGroup;
+ (void)setAccessGroup:(NSString *)accessGroup;

@end
