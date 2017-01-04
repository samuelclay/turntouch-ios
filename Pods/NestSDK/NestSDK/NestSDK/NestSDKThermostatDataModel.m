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

#import "NestSDKThermostatDataModel.h"
#import "NestSDKUtils.h"

#pragma mark const

static NSString *const kTemperatureScaleStringC = @"C";
static NSString *const kTemperatureScaleStringF = @"F";

static NSString *const kHVACStateStringOff = @"off";
static NSString *const kHVACStateStringCooling = @"cooling";
static NSString *const kHVACStateStringHeating = @"heating";

static NSString *const kHVACModeStringHeat = @"heat";
static NSString *const kHVACModeStringCool = @"cool";
static NSString *const kHVACModeStringHeatCool = @"heat-cool";
static NSString *const kHVACModeStringOff = @"off";

const NSUInteger NestSDKThermostatTemperatureCAllowableMin = 9;
const NSUInteger NestSDKThermostatTemperatureCAllowableMax = 32;

const NSUInteger NestSDKThermostatTemperatureFAllowableMin = 50;
const NSUInteger NestSDKThermostatTemperatureFAllowableMax = 90;


@implementation NestSDKThermostatDataModel
#pragma mark Private

- (CGFloat)_temperatureInAllowableRangeWithTemperature:(CGFloat)temperature
                                          allowableMin:(NSUInteger)allowableMin
                                          allowableMax:(NSUInteger)allowableMax {

    if (temperature < allowableMin) return allowableMin;
    if (temperature > allowableMax) return allowableMax;

    return temperature;
}

- (CGFloat)_temperatureInAllowableRangeWithTemperatureC:(CGFloat)temperatureC {
    return [self _temperatureInAllowableRangeWithTemperature:temperatureC
                                                allowableMin:NestSDKThermostatTemperatureCAllowableMin
                                                allowableMax:NestSDKThermostatTemperatureCAllowableMax];
}

- (NSUInteger)_temperatureInAllowableRangeWithTemperatureF:(NSUInteger)temperatureF {
    return (NSUInteger) [self _temperatureInAllowableRangeWithTemperature:temperatureF
                                                             allowableMin:NestSDKThermostatTemperatureFAllowableMin
                                                             allowableMax:NestSDKThermostatTemperatureFAllowableMax];
}

- (NSArray *)_writablePropertyNamesArraySatisfyingTemperatureScaleWithArray:(NSArray *)array {
    NSString *suffix;

    switch (self.temperatureScale) {
        case NestSDKThermostatTemperatureScaleUndefined:
            break;

        case NestSDKThermostatTemperatureScaleC:
            suffix = @"F";

            break;
        case NestSDKThermostatTemperatureScaleF:
            suffix = @"C";

            break;
    }

    NSArray *propertyNamesToRemoveArray = [self _writableTemperaturePropertyNameWithSuffix:suffix];

    NSMutableArray *mutableArray = [array mutableCopy];
    [mutableArray removeObjectsInArray:propertyNamesToRemoveArray];

    return mutableArray;
}

- (NSArray *)_writableTemperaturePropertyNameWithSuffix:(NSString *)suffix {
    if (suffix.length == 0) return @[];

    NSString *targetTemperature = [self _temperaturePropertyWithName:@"targetTemperature" suffix:suffix];
    NSString *targetTemperatureHigh = [self _temperaturePropertyWithName:@"targetTemperatureHigh" suffix:suffix];
    NSString *targetTemperatureLow = [self _temperaturePropertyWithName:@"targetTemperatureLow" suffix:suffix];

    return @[targetTemperature, targetTemperatureHigh, targetTemperatureLow];
}

- (NSString *)_temperaturePropertyWithName:(NSString *)propertyName suffix:(NSString *)suffix {
    return [NSString stringWithFormat:@"%@%@", propertyName, suffix];
}

#pragma mark Override

- (void)setTargetTemperatureF:(NSUInteger)targetTemperatureF {
    _targetTemperatureF = [self _temperatureInAllowableRangeWithTemperatureF:targetTemperatureF];
}

- (void)setTargetTemperatureC:(CGFloat)targetTemperatureC {
    _targetTemperatureC = [self _temperatureInAllowableRangeWithTemperatureC:targetTemperatureC];
}

- (void)setTargetTemperatureHighF:(NSUInteger)targetTemperatureHighF {
    _targetTemperatureHighF = [self _temperatureInAllowableRangeWithTemperatureF:targetTemperatureHighF];
}

- (void)setTargetTemperatureHighC:(CGFloat)targetTemperatureHighC {
    _targetTemperatureHighC = [self _temperatureInAllowableRangeWithTemperatureC:targetTemperatureHighC];
}

- (void)setTargetTemperatureLowF:(NSUInteger)targetTemperatureLowF {
    _targetTemperatureLowF = [self _temperatureInAllowableRangeWithTemperatureF:targetTemperatureLowF];
}

- (void)setTargetTemperatureLowC:(CGFloat)targetTemperatureLowC {
    _targetTemperatureLowC = [self _temperatureInAllowableRangeWithTemperatureC:targetTemperatureLowC];
}

- (void)setHvacMode:(NestSDKThermostatHVACMode)hvacMode {
    _hvacMode = hvacMode;
}

- (void)setFanTimerTimeout:(NSDate <Optional> *)fanTimerTimeout {
    _fanTimerTimeout = fanTimerTimeout;
}

- (void)setLastConnectionWithNSString:(NSString *)lastConnectionString {
    self.lastConnection = [NestSDKUtils dateWithISO8601FormatDateString:lastConnectionString];
}

- (id)JSONObjectForLastConnection {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.lastConnection];
}

- (void)setFanTimerTimeoutWithNSString:(NSString *)fanTimerTimeoutString {
    self.fanTimerTimeout = [NestSDKUtils dateWithISO8601FormatDateString:fanTimerTimeoutString];
}

- (id)JSONObjectForFanTimerTimeout {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.fanTimerTimeout];
}

- (void)setTemperatureScaleWithNSString:(NSString *)temperatureScaleString {
    if ([temperatureScaleString isEqualToString:kTemperatureScaleStringC]) {
        self.temperatureScale = NestSDKThermostatTemperatureScaleC;

    } else if ([temperatureScaleString isEqualToString:kTemperatureScaleStringF]) {
        self.temperatureScale = NestSDKThermostatTemperatureScaleF;

    } else {
        self.temperatureScale = NestSDKThermostatTemperatureScaleUndefined;
    }
}

- (id)JSONObjectForTemperatureScale {
    switch (self.temperatureScale) {
        case NestSDKThermostatTemperatureScaleUndefined:
            return nil;

        case NestSDKThermostatTemperatureScaleC:
            return kTemperatureScaleStringC;

        case NestSDKThermostatTemperatureScaleF:
            return kTemperatureScaleStringF;
    }

    return nil;
}

- (void)setHvacStateWithNSString:(NSString *)fanHVACStateString {
    if ([fanHVACStateString isEqualToString:kHVACStateStringHeating]) {
        self.hvacState = NestSDKThermostatHVACStateHeating;

    } else if ([fanHVACStateString isEqualToString:kHVACStateStringCooling]) {
        self.hvacState = NestSDKThermostatHVACStateCooling;

    } else if ([fanHVACStateString isEqualToString:kHVACStateStringOff]) {
        self.hvacState = NestSDKThermostatHVACStateOff;

    } else {
        self.hvacState = NestSDKThermostatHVACStateUndefined;
    }
}

- (id)JSONObjectForHvacState {
    switch (self.hvacState) {
        case NestSDKThermostatHVACStateUndefined:
            return nil;

        case NestSDKThermostatHVACStateHeating:
            return kHVACStateStringHeating;

        case NestSDKThermostatHVACStateCooling:
            return kHVACStateStringCooling;

        case NestSDKThermostatHVACStateOff:
            return kHVACStateStringOff;
    }

    return nil;
}

- (void)setHvacModeWithNSString:(NSString *)hvacModeString {
    if ([hvacModeString isEqualToString:kHVACModeStringHeat]) {
        self.hvacMode = NestSDKThermostatHVACModeHeat;

    } else if ([hvacModeString isEqualToString:kHVACModeStringCool]) {
        self.hvacMode = NestSDKThermostatHVACModeCool;

    } else if ([hvacModeString isEqualToString:kHVACModeStringHeatCool]) {
        self.hvacMode = NestSDKThermostatHVACModeHeatCool;

    } else if ([hvacModeString isEqualToString:kHVACModeStringOff]) {
        self.hvacMode = NestSDKThermostatHVACModeOff;

    } else {
        self.hvacMode = NestSDKThermostatHVACModeUndefined;
    }
}

- (id)JSONObjectForHvacMode {
    switch (self.hvacMode) {
        case NestSDKThermostatHVACModeUndefined:
            return nil;

        case NestSDKThermostatHVACModeHeat:
            return kHVACModeStringHeat;

        case NestSDKThermostatHVACModeCool:
            return kHVACModeStringCool;

        case NestSDKThermostatHVACModeHeatCool:
            return kHVACModeStringHeatCool;

        case NestSDKThermostatHVACModeOff:
            return kHVACModeStringOff;
    }

    return nil;
}

- (NSArray *)writablePropertyNamesArrayWithProtocol:(Protocol *)aProtocol {
    NSArray *array = [super writablePropertyNamesArrayWithProtocol:aProtocol];
    array = [self _writablePropertyNamesArraySatisfyingTemperatureScaleWithArray:array];

    return array;
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKThermostatDataModel *thermostatDataModelCopy = (NestSDKThermostatDataModel *) copy;
    thermostatDataModelCopy.locale = self.locale;
    thermostatDataModelCopy.lastConnection = self.lastConnection;
    thermostatDataModelCopy.canCool = self.canCool;
    thermostatDataModelCopy.canHeat = self.canHeat;
    thermostatDataModelCopy.isUsingEmergencyHeat = self.isUsingEmergencyHeat;
    thermostatDataModelCopy.hasFan = self.hasFan;
    thermostatDataModelCopy.fanTimerActive = self.fanTimerActive;
    thermostatDataModelCopy.fanTimerTimeout = self.fanTimerTimeout;
    thermostatDataModelCopy.hasLeaf = self.hasLeaf;
    thermostatDataModelCopy.temperatureScale = self.temperatureScale;
    thermostatDataModelCopy.targetTemperatureF = self.targetTemperatureF;
    thermostatDataModelCopy.targetTemperatureC = self.targetTemperatureC;
    thermostatDataModelCopy.targetTemperatureHighF = self.targetTemperatureHighF;
    thermostatDataModelCopy.targetTemperatureHighC = self.targetTemperatureHighC;
    thermostatDataModelCopy.targetTemperatureLowF = self.targetTemperatureLowF;
    thermostatDataModelCopy.targetTemperatureLowC = self.targetTemperatureLowC;
    thermostatDataModelCopy.awayTemperatureHighF = self.awayTemperatureHighF;
    thermostatDataModelCopy.awayTemperatureHighC = self.awayTemperatureHighC;
    thermostatDataModelCopy.awayTemperatureLowF = self.awayTemperatureLowF;
    thermostatDataModelCopy.awayTemperatureLowC = self.awayTemperatureLowC;
    thermostatDataModelCopy.hvacMode = self.hvacMode;
    thermostatDataModelCopy.ambientTemperatureC = self.ambientTemperatureC;
    thermostatDataModelCopy.ambientTemperatureF = self.ambientTemperatureF;
    thermostatDataModelCopy.humidity = self.humidity;
    thermostatDataModelCopy.hvacState = self.hvacState;
}

- (NSUInteger)hash {
    NSUInteger intValueForYes = 1231;
    NSUInteger intValueForNo = 1237;

    NSUInteger prime = 31;
    NSUInteger result = [super hash];

    result = prime * result + self.lastConnection.hash;
    result = prime * result + self.locale.hash;
    result = prime * result + (self.canCool ? intValueForYes : intValueForNo);
    result = prime * result + (self.canHeat ? intValueForYes : intValueForNo);
    result = prime * result + (self.isUsingEmergencyHeat ? intValueForYes : intValueForNo);
    result = prime * result + (self.hasFan ? intValueForYes : intValueForNo);
    result = prime * result + (self.fanTimerActive ? intValueForYes : intValueForNo);
    result = prime * result + self.fanTimerTimeout.hash;
    result = prime * result + (self.hasLeaf ? intValueForYes : intValueForNo);
    result = prime * result + self.temperatureScale;
    result = prime * result + self.targetTemperatureF;
    result = (NSUInteger) (prime * result + self.targetTemperatureC);
    result = prime * result + self.targetTemperatureHighF;
    result = (NSUInteger) (prime * result + self.targetTemperatureHighC);
    result = prime * result + self.targetTemperatureLowF;
    result = (NSUInteger) (prime * result + self.targetTemperatureLowC);
    result = prime * result + self.awayTemperatureHighF;
    result = (NSUInteger) (prime * result + self.awayTemperatureHighC);
    result = prime * result + self.awayTemperatureLowF;
    result = (NSUInteger) (prime * result + self.awayTemperatureLowC);
    result = prime * result + self.hvacMode;
    result = (NSUInteger) (prime * result + self.ambientTemperatureC);
    result = prime * result + self.ambientTemperatureF;
    result = prime * result + self.humidity;
    result = prime * result + self.hvacState;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    if (![super isEqual:other])
        return NO;

    NestSDKThermostatDataModel *otherThermostat = (NestSDKThermostatDataModel *) other;
    return (([NestSDKUtils object:self.lastConnection isEqualToObject:otherThermostat.lastConnection]) &&
            ([NestSDKUtils object:self.locale isEqualToObject:otherThermostat.locale]) &&
            (self.canCool == otherThermostat.canCool) &&
            (self.canHeat == otherThermostat.canHeat) &&
            (self.isUsingEmergencyHeat == otherThermostat.isUsingEmergencyHeat) &&
            (self.hasFan == otherThermostat.hasFan) &&
            (self.fanTimerActive == otherThermostat.fanTimerActive) &&
            ([NestSDKUtils object:self.fanTimerTimeout isEqualToObject:otherThermostat.fanTimerTimeout]) &&
            (self.hasLeaf == otherThermostat.hasLeaf) &&
            (self.temperatureScale == otherThermostat.temperatureScale) &&
            (self.targetTemperatureF == otherThermostat.targetTemperatureF) &&
            (self.targetTemperatureC == otherThermostat.targetTemperatureC) &&
            (self.targetTemperatureHighF == otherThermostat.targetTemperatureHighF) &&
            (self.targetTemperatureHighC == otherThermostat.targetTemperatureHighC) &&
            (self.targetTemperatureLowF == otherThermostat.targetTemperatureLowF) &&
            (self.targetTemperatureLowC == otherThermostat.targetTemperatureLowC) &&
            (self.awayTemperatureHighF == otherThermostat.awayTemperatureHighF) &&
            (self.awayTemperatureHighC == otherThermostat.awayTemperatureHighC) &&
            (self.awayTemperatureLowF == otherThermostat.awayTemperatureLowF) &&
            (self.awayTemperatureLowC == otherThermostat.awayTemperatureLowC) &&
            (self.hvacMode == otherThermostat.hvacMode) &&
            (self.ambientTemperatureC == otherThermostat.ambientTemperatureC) &&
            (self.ambientTemperatureF == otherThermostat.ambientTemperatureF) &&
            (self.humidity == otherThermostat.humidity) &&
            (self.hvacState == otherThermostat.hvacState));
}

@end