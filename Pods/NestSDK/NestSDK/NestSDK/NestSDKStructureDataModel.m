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

#import "NestSDKDataModel.h"
#import "NestSDKStructureDataModel.h"
#import "NestSDKUtils.h"

#pragma mark const

static NSString *const kAwayStringAway = @"away";
static NSString *const kAwayStringHome = @"home";
static NSString *const kAwayStringAutoAway = @"auto-away";


@implementation NestSDKStructureDataModel
#pragma mark Override

- (void)setPeakPeriodStartTimeWithNSString:(NSString *)peakPeriodStartTimeString {
    self.peakPeriodStartTime = [NestSDKUtils dateWithISO8601FormatDateString:peakPeriodStartTimeString];
}

- (id)JSONObjectForPeakPeriodStartTime {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.peakPeriodStartTime];
}

- (void)setPeakPeriodEndTimeWithNSString:(NSString *)peakPeriodEndTimeString {
    self.peakPeriodEndTime = [NestSDKUtils dateWithISO8601FormatDateString:peakPeriodEndTimeString];
}

- (id)JSONObjectForPeakPeriodEndTime {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.peakPeriodEndTime];
}

- (void)setAwayWithNSString:(NSString *)awayString {
    if ([awayString isEqualToString:kAwayStringAway]) {
        self.away = NestSDKStructureAwayStateAway;

    } else if ([awayString isEqualToString:kAwayStringHome]) {
        self.away = NestSDKStructureAwayStateHome;

    } else if ([awayString isEqualToString:kAwayStringAutoAway]) {
        self.away = NestSDKStructureAwayStateAutoAway;
    }
}

- (id)JSONObjectForAway {
    switch (self.away) {
        case NestSDKStructureAwayStateUndefined:
            return nil;

        case NestSDKStructureAwayStateHome:
            return kAwayStringHome;

        case NestSDKStructureAwayStateAway:
            return kAwayStringAway;

        case NestSDKStructureAwayStateAutoAway:
            return kAwayStringAutoAway;
    }

    return nil;
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKStructureDataModel *structureDataModelCopy = (NestSDKStructureDataModel *) copy;
    structureDataModelCopy.structureId = self.structureId;
    structureDataModelCopy.thermostats = self.thermostats;
    structureDataModelCopy.smokeCoAlarms = self.smokeCoAlarms;
    structureDataModelCopy.cameras = self.cameras;
    structureDataModelCopy.devices = self.devices;
    structureDataModelCopy.away = self.away;
    structureDataModelCopy.name = self.name;
    structureDataModelCopy.countryCode = self.countryCode;
    structureDataModelCopy.postalCode = self.postalCode;
    structureDataModelCopy.peakPeriodStartTime = self.peakPeriodStartTime;
    structureDataModelCopy.peakPeriodEndTime = self.peakPeriodEndTime;
    structureDataModelCopy.timeZone = self.timeZone;
    structureDataModelCopy.eta = self.eta;
    structureDataModelCopy.rhrEnrollment = self.rhrEnrollment;
    structureDataModelCopy.wheres = self.wheres;
}

- (NSUInteger)hash {
    NSUInteger intValueForYes = 1231;
    NSUInteger intValueForNo = 1237;

    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + self.structureId.hash;
    result = prime * result + self.thermostats.hash;
    result = prime * result + self.smokeCoAlarms.hash;
    result = prime * result + self.cameras.hash;
    result = prime * result + self.devices.hash;
    result = prime * result + self.away;
    result = prime * result + self.name.hash;
    result = prime * result + self.countryCode.hash;
    result = prime * result + self.postalCode.hash;
    result = prime * result + self.peakPeriodStartTime.hash;
    result = prime * result + self.peakPeriodEndTime.hash;
    result = prime * result + self.timeZone.hash;
    result = prime * result + self.eta.hash;
    result = prime * result + (self.rhrEnrollment ? intValueForYes : intValueForNo);
    result = prime * result + self.wheres.hash;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    NestSDKStructureDataModel *otherStructure = (NestSDKStructureDataModel *) other;
    return ([NestSDKUtils object:self.structureId isEqualToObject:otherStructure.structureId] &&
            ([NestSDKUtils object:self.structureId isEqualToObject:otherStructure.structureId]) &&
            ([NestSDKUtils object:self.thermostats isEqualToObject:otherStructure.thermostats]) &&
            ([NestSDKUtils object:self.smokeCoAlarms isEqualToObject:otherStructure.smokeCoAlarms]) &&
            ([NestSDKUtils object:self.cameras isEqualToObject:otherStructure.cameras]) &&
            ([NestSDKUtils object:self.devices isEqualToObject:otherStructure.devices]) &&
            (self.away == otherStructure.away) &&
            ([NestSDKUtils object:self.name isEqualToObject:otherStructure.name]) &&
            ([NestSDKUtils object:self.countryCode isEqualToObject:otherStructure.countryCode]) &&
            ([NestSDKUtils object:self.postalCode isEqualToObject:otherStructure.postalCode]) &&
            ([NestSDKUtils object:self.peakPeriodStartTime isEqualToObject:otherStructure.peakPeriodStartTime]) &&
            ([NestSDKUtils object:self.peakPeriodEndTime isEqualToObject:otherStructure.peakPeriodEndTime]) &&
            ([NestSDKUtils object:self.timeZone isEqualToObject:otherStructure.timeZone]) &&
            ([NestSDKUtils object:self.eta isEqualToObject:otherStructure.eta]) &&
            (self.rhrEnrollment == otherStructure.rhrEnrollment) &&
            ([NestSDKUtils object:self.wheres isEqualToObject:otherStructure.wheres]));
}

@end