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
#import <JSONModel/JSONModel.h>
#import "NestSDKDeviceDataModel.h"
#import "NestSDKSmokeCOAlarm.h"


/**
 * Smoke+CO alarm data model
 */
@interface NestSDKSmokeCOAlarmDataModel : NestSDKDeviceDataModel <NestSDKSmokeCOAlarm>
#pragma mark Properties

/**
 * Specifies language and region (or country) preference.
 */
@property(nonatomic, copy) NSString <Optional> *locale;

/**
 * Timestamp of the last successful interaction with the Nest service.
 */
@property(nonatomic) NSDate <Optional> *lastConnection;

/**
 * Battery life/health; estimate of remaining battery power level.
 */
@property(nonatomic) NestSDKSmokeCOAlarmBatteryHealth batteryHealth;

/**
 * CO alarm status.
 */
@property(nonatomic) NestSDKSmokeCOAlarmAlarmState coAlarmState;

/**
 * Smoke alarm status.
 */
@property(nonatomic) NestSDKSmokeCOAlarmAlarmState smokeAlarmState;

/**
 * State of the manual smoke and CO alarm test.
 */
@property(nonatomic) BOOL isManualTestActive;

/**
 * Timestamp of the last successful manual smoke and CO alarm test.
 */
@property(nonatomic) NSDate <Optional> *lastManualTestTime;

/**
 * Indicates device status by color in the Nest app UI.
 * It is an aggregate condition for battery+smoke+co states, and reflects the actual color indicators displayed in the Nest app.
 *
 * Learn more about color indicators on the Nest Protect: http://support.nest.com/article/What-do-the-lights-mean-on-Nest-Protect
 * Learn more about color indicators for the Nest Protect battery: http://support.nest.com/article/How-do-I-check-the-level-of-my-Nest-Protect-battery
 */
@property(nonatomic) NestSDKSmokeCOAlarmUIColorState uiColorState;

@end