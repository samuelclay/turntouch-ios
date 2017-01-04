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
#import <NestSDK/NestSDKDevice.h>

@protocol NestSDKCameraLastEvent;

/**
 * Camera device data model protocol.
 */
@protocol NestSDKCamera <NestSDKDevice>
#pragma mark Properties

/**
 * Camera status, either on and actively streaming video, or off.
 *
 * Learn how to set Nest Cam streaming based on Away mode: https://nest.com/ie/support/article/Can-I-have-my-Nest-Cam-turn-on-automatically-when-my-Nest-Thermostat-goes-into-Away-mode
 */
@property(nonatomic) BOOL isStreaming;
/**
 * Camera microphone status, either on and listening, or off.
 *
 * Learn more about Nest Cam audio setting: https://nest.com/support/article/Does-Nest-Cam-have-audio
 */
@property(nonatomic, readonly) BOOL isAudioInputEnabled;

/**
 * Timestamp that identifies the last change to the online status.
 */
@property(nonatomic, readonly) NSDate *lastIsOnlineChange;

/**
 * Nest Aware with Video History subscription status (subscription active or not).
 *
 * Learn more about Nest Aware with Video History: https://nest.com/support/article/What-do-I-get-with-Nest-Aware-for-Nest-Cam
 */
@property(nonatomic, readonly) BOOL isVideoHistoryEnabled;

/**
 * Web URL (deep link) to the live camera feed at home.nest.com.
 */
@property(nonatomic, copy, readonly) NSString *webUrl;

/**
 * App URL (deep link) to the live camera feed in the Nest app.
 */
@property(nonatomic, copy, readonly) NSString *appUrl;

/**
 * This object captures information about the last event that triggered a notification.
 * In order to capture last event data, the Nest Cam must have a Nest Aware with Video History subscription.
 */
@property(nonatomic, readonly) id <NestSDKCameraLastEvent> lastEvent;


@end