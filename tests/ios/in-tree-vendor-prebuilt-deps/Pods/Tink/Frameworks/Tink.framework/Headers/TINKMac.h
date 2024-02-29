/**
 * Copyright 2017 Google Inc.
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
 *
 **************************************************************************
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol for MACs (Message Authentication Codes).
 * Instances that conform to this protocol should be used for authentication only and not for other
 * purposes (e.g., it should not be used to generate pseudorandom bytes).
 */
@protocol TINKMac

/* Computes and returns the message authentication code (MAC) for @c data. */
- (nullable NSData *)computeMacForData:(NSData *)data error:(NSError **)error;

/**
 * Verifies if @c mac is a correct authentication code (MAC) for @c data.
 * Returns YES if @c mac is correct, NO otherwise.
 */
- (BOOL)verifyMac:(NSData *)mac forData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
