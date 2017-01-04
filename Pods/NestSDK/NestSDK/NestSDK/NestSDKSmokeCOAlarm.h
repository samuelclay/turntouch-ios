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

#pragma mark typedef
/**
 * Battery health property values
 */
typedef NS_ENUM(NSUInteger, NestSDKSmokeCOAlarmBatteryHealth) {
    NestSDKSmokeCOAlarmBatteryHealthUndefined = 0,
    NestSDKSmokeCOAlarmBatteryHealthOk,
    NestSDKSmokeCOAlarmBatteryHealthReplace
};

/**
 * Alarm state property values
 */
typedef NS_ENUM(NSUInteger, NestSDKSmokeCOAlarmAlarmState) {
    NestSDKSmokeCOAlarmAlarmStateUndefined = 0,
    NestSDKSmokeCOAlarmAlarmStateOk,
    NestSDKSmokeCOAlarmAlarmStateWarning,
    NestSDKSmokeCOAlarmAlarmStateEmergency
};

/**
 * UIColor property values
 */
typedef NS_ENUM(NSUInteger, NestSDKSmokeCOAlarmUIColorState) {
    NestSDKSmokeCOAlarmUIColorStateUndefined = 0,
    NestSDKSmokeCOAlarmUIColorStateGray,
    NestSDKSmokeCOAlarmUIColorStateGreen,
    NestSDKSmokeCOAlarmUIColorStateYellow,
    NestSDKSmokeCOAlarmUIColorStateRed
};


/**
 * Smoke+CO alarm data model protocol
 */
@protocol NestSDKSmokeCOAlarm <NestSDKDevice>
#pragma mark Properties

/**
 * Specifies language and region (or country) preference.
 */
@property(nonatomic, copy, readonly) NSString *locale;

/**
 * Timestamp of the last successful interaction with the Nest service.
 */
@property(nonatomic, readonly) NSDate *lastConnection;

/**
 * Battery life/health; estimate of remaining battery power level.
 */
@property(nonatomic, readonly) NestSDKSmokeCOAlarmBatteryHealth batteryHealth;

/**
 * CO alarm status.
 */
@property(nonatomic, readonly) NestSDKSmokeCOAlarmAlarmState coAlarmState;

/**
 * Smoke alarm status.
 */
@property(nonatomic, readonly) NestSDKSmokeCOAlarmAlarmState smokeAlarmState;

/**
 * State of the manual smoke and CO alarm test.
 */
@property(nonatomic, readonly) BOOL isManualTestActive;

/**
 * Timestamp of the last successful manual smoke and CO alarm test.
 */
@property(nonatomic, readonly) NSDate *lastManualTestTime;

/**
 * Indicates device status by color in the Nest app UI.
 * It is an aggregate condition for battery+smoke+co states, and reflects the actual color indicators displayed in the Nest app.
 *
 * Learn more about color indicators on the Nest Protect: http://support.nest.com/article/What-do-the-lights-mean-on-Nest-Protect
 * Learn more about color indicators for the Nest Protect battery: http://support.nest.com/article/How-do-I-check-the-level-of-my-Nest-Protect-battery
 */
@property(nonatomic, readonly) NestSDKSmokeCOAlarmUIColorState uiColorState;

@end