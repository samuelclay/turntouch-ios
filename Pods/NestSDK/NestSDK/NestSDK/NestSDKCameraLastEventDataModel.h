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
#import "NestSDKDataModel.h"
#import "NestSDKCameraLastEvent.h"

/**
 * Camera last event data model.
 *
 * This object captures information about the last event that triggered a notification.
 * In order to capture last event data, the Nest Cam must have a Nest Aware with Video History subscription.
 *
 * Learn more about Nest Aware with Video History subscription: https://nest.com/support/article/What-do-I-get-with-Nest-Aware-for-Nest-Cam
 */
@interface NestSDKCameraLastEventDataModel : NestSDKDataModel <NestSDKCameraLastEvent>
#pragma mark Properties

/**
 * Sound event - sound was detected.
 */
@property(nonatomic) BOOL hasSound;

/**
 * Motion event - motion was detected.
 */
@property(nonatomic) BOOL hasMotion;

/**
 * Event start time.
 */
@property(nonatomic) NSDate <Optional> *startTime;

/**
 * Event end time.
 */
@property(nonatomic) NSDate <Optional> *endTime;

/**
 * Web URL (deep link) to the last sound or motion event at home.nest.com.
 * Used to display the last recorded event, and requires user to be signed in to the account.
 */
@property(nonatomic, copy) NSString <Optional> *webUrl;

/**
 * Nest app URL (deep link) to the last sound or motion event.
 * Used to display the last recorded event, and requires user to be signed in to the account.
 */
@property(nonatomic, copy) NSString <Optional> *appUrl;

/**
 * URL (link) to the image file captured for a sound or motion event.
 */
@property(nonatomic, copy) NSString <Optional> *imageUrl;

/**
 * URL (link) to the gif file captured for a sound or motion event.
 */
@property(nonatomic, copy) NSString <Optional> *animatedImageUrl;

@end