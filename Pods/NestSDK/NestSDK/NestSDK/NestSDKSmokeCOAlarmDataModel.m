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

#import "NestSDKSmokeCOAlarmDataModel.h"
#import "NestSDKUtils.h"

#pragma mark const
static NSString *const kBatteryHealthStringOk = @"ok";
static NSString *const kBatteryHealthStringReplace = @"replace";

static NSString *const kAlarmStateStringOk = @"ok";
static NSString *const kAlarmStateStringWarning = @"warning";
static NSString *const kAlarmStateStringEmergency = @"emergency";

static NSString *const kUIColorStateGray = @"gray";
static NSString *const kUIColorStateGreen = @"green";
static NSString *const kUIColorStateYellow = @"yellow";
static NSString *const kUIColorStateRed = @"red";


@implementation NestSDKSmokeCOAlarmDataModel
#pragma mark Private

- (NestSDKSmokeCOAlarmAlarmState)_alarmStateWithAlarmStateString:(NSString *)alarmStateString {
    NestSDKSmokeCOAlarmAlarmState alarmState = NestSDKSmokeCOAlarmAlarmStateUndefined;

    if ([alarmStateString isEqualToString:kAlarmStateStringOk]) {
        alarmState = NestSDKSmokeCOAlarmAlarmStateOk;

    } else if ([alarmStateString isEqualToString:kAlarmStateStringWarning]) {
        alarmState = NestSDKSmokeCOAlarmAlarmStateWarning;

    } else if ([alarmStateString isEqualToString:kAlarmStateStringEmergency]) {
        alarmState = NestSDKSmokeCOAlarmAlarmStateEmergency;
    }

    return alarmState;
}

- (NSString *)_alarmStateStringWithAlarmState:(NestSDKSmokeCOAlarmAlarmState)alarmState {
    switch (alarmState) {
        case NestSDKSmokeCOAlarmAlarmStateUndefined:
            return nil;

        case NestSDKSmokeCOAlarmAlarmStateOk:
            return kAlarmStateStringOk;

        case NestSDKSmokeCOAlarmAlarmStateWarning:
            return kAlarmStateStringWarning;

        case NestSDKSmokeCOAlarmAlarmStateEmergency:
            return kAlarmStateStringEmergency;
    }

    return nil;
}


#pragma mark Override

- (void)setLastConnectionWithNSString:(NSString *)lastConnectionString {
    self.lastConnection = [NestSDKUtils dateWithISO8601FormatDateString:lastConnectionString];
}

- (id)JSONObjectForLastConnection {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.lastConnection];
}

- (void)setLastManualTestTimeWithNSString:(NSString *)lastManualTestTimeString {
    self.lastManualTestTime = [NestSDKUtils dateWithISO8601FormatDateString:lastManualTestTimeString];
}

- (id)JSONObjectForLastManualTestTime {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.lastManualTestTime];
}

- (void)setBatteryHealthWithNSString:(NSString *)batteryHealthString {
    if ([batteryHealthString isEqualToString:kBatteryHealthStringOk]) {
        self.batteryHealth = NestSDKSmokeCOAlarmBatteryHealthOk;

    } else if ([batteryHealthString isEqualToString:kBatteryHealthStringReplace]) {
        self.batteryHealth = NestSDKSmokeCOAlarmBatteryHealthReplace;

    } else {
        self.batteryHealth = NestSDKSmokeCOAlarmBatteryHealthUndefined;
    }
}

- (id)JSONObjectForBatteryHealth {
    switch (self.batteryHealth) {
        case NestSDKSmokeCOAlarmBatteryHealthUndefined:
            return nil;

        case NestSDKSmokeCOAlarmBatteryHealthOk:
            return kBatteryHealthStringOk;

        case NestSDKSmokeCOAlarmBatteryHealthReplace:
            return kBatteryHealthStringReplace;
    }

    return nil;
}

- (void)setCoAlarmStateWithNSString:(NSString *)alarmStateString {
    self.coAlarmState = [self _alarmStateWithAlarmStateString:alarmStateString];
}

- (id)JSONObjectForCoAlarmState {
    return [self _alarmStateStringWithAlarmState:self.coAlarmState];
}

- (void)setSmokeAlarmStateWithNSString:(NSString *)alarmStateString {
    self.smokeAlarmState = [self _alarmStateWithAlarmStateString:alarmStateString];
}

- (id)JSONObjectForSmokeAlarmState {
    return [self _alarmStateStringWithAlarmState:self.smokeAlarmState];
}

- (void)setUiColorStateWithNSString:(NSString *)uiColorStateString {
    if ([uiColorStateString isEqualToString:kUIColorStateGray]) {
        self.uiColorState = NestSDKSmokeCOAlarmUIColorStateGray;

    } else if ([uiColorStateString isEqualToString:kUIColorStateGreen]) {
        self.uiColorState = NestSDKSmokeCOAlarmUIColorStateGreen;

    } else if ([uiColorStateString isEqualToString:kUIColorStateYellow]) {
        self.uiColorState = NestSDKSmokeCOAlarmUIColorStateYellow;

    } else if ([uiColorStateString isEqualToString:kUIColorStateRed]) {
        self.uiColorState = NestSDKSmokeCOAlarmUIColorStateRed;

    } else {
        self.uiColorState = NestSDKSmokeCOAlarmUIColorStateUndefined;
    }
}

- (id)JSONObjectForUiColorState {
    switch (self.uiColorState) {
        case NestSDKSmokeCOAlarmUIColorStateUndefined:
            return nil;

        case NestSDKSmokeCOAlarmUIColorStateGray:
            return kUIColorStateGray;

        case NestSDKSmokeCOAlarmUIColorStateGreen:
            return kUIColorStateGreen;

        case NestSDKSmokeCOAlarmUIColorStateYellow:
            return kUIColorStateYellow;

        case NestSDKSmokeCOAlarmUIColorStateRed:
            return kUIColorStateRed;
    }

    return nil;
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKSmokeCOAlarmDataModel *smokeCOAlarmDataModelCopy = (NestSDKSmokeCOAlarmDataModel *) copy;
    smokeCOAlarmDataModelCopy.locale = self.locale;
    smokeCOAlarmDataModelCopy.lastConnection = self.lastConnection;
    smokeCOAlarmDataModelCopy.batteryHealth = self.batteryHealth;
    smokeCOAlarmDataModelCopy.coAlarmState = self.coAlarmState;
    smokeCOAlarmDataModelCopy.smokeAlarmState = self.smokeAlarmState;
    smokeCOAlarmDataModelCopy.isManualTestActive = self.isManualTestActive;
    smokeCOAlarmDataModelCopy.lastManualTestTime = self.lastManualTestTime;
    smokeCOAlarmDataModelCopy.uiColorState = self.uiColorState;
}

- (NSUInteger)hash {
    NSUInteger intValueForYes = 1231;
    NSUInteger intValueForNo = 1237;

    NSUInteger prime = 31;
    NSUInteger result = [super hash];

    result = prime * result + self.lastConnection.hash;
    result = prime * result + self.locale.hash;
    result = prime * result + self.batteryHealth;
    result = prime * result + self.coAlarmState;
    result = prime * result + self.smokeAlarmState;
    result = prime * result + (self.isManualTestActive ? intValueForYes : intValueForNo);
    result = prime * result + self.lastManualTestTime.hash;
    result = prime * result + self.uiColorState;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    if (![super isEqual:other])
        return NO;

    NestSDKSmokeCOAlarmDataModel *otherSmokeCOAlarm = (NestSDKSmokeCOAlarmDataModel *) other;
    return (([NestSDKUtils object:self.lastConnection isEqualToObject:otherSmokeCOAlarm.lastConnection]) &&
            ([NestSDKUtils object:self.locale isEqualToObject:otherSmokeCOAlarm.locale]) &&
            (self.batteryHealth == otherSmokeCOAlarm.batteryHealth) &&
            (self.coAlarmState == otherSmokeCOAlarm.coAlarmState) &&
            (self.smokeAlarmState == otherSmokeCOAlarm.smokeAlarmState) &&
            (self.isManualTestActive == otherSmokeCOAlarm.isManualTestActive) &&
            ([NestSDKUtils object:self.lastManualTestTime isEqualToObject:otherSmokeCOAlarm.lastManualTestTime]) &&
            (self.uiColorState == otherSmokeCOAlarm.uiColorState));
}

@end