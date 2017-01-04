// Copyright (c) 2016 Petro Akzhygitov <petro.akzhygitov@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

#pragma mark typedef

/**
 * Handle used to unregister observers.
 */
typedef NSUInteger NestSDKObserverHandle;

/**
 * Describes the result of service request or data update.
 */
typedef void (^NestSDKServiceUpdateBlock)(id result, NSError *error);

/**
 * Protocol for NestSDK service. Each NestSDK service should conform this protocol.
 */
@protocol NestSDKService <NSObject>
#pragma mark Methods

/**
 * Get data from a particular location. Your block will be triggered when data is delivered.
 *
 * @param url Location to get data from.
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)valuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block;

/**
 * Set data to a particular location. Your block will be triggered when data is set.
 *
 * @param values NSDictionary with values to be set.
 * @param url Location to set data to.
 * @param block The block that should be called when data is set or error happen.
 */
- (void)setValues:(NSDictionary *)values forURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block;

/**
 * observeValuesForURL:withBlock: is used to listen for data changes at a particular location.
 * Your block will be triggered for the initial data and again whenever the data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param url URL to listen for data change.
 * @param block The block that should be called with initial data, updates or errors happen.
 * @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (NestSDKObserverHandle)observeValuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block;

/**
 * Detach a block previously attached with observeValuesForURL:withBlock:.
 *
 * @param handle The handle returned by the call to observeValuesForURL:withBlock: which block should be removed.
 */
- (void)removeObserverWithHandle:(NestSDKObserverHandle)handle;

/**
 * Detach all blocks previously attached to this service with observeValuesForURL:withBlock:
 */
- (void)removeAllObservers;

@end