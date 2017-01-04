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

#import <JSONModel/JSONModel.h>
#import "NestSDKETADataModel.h"
#import "NestSDKUtils.h"

@implementation NestSDKETADataModel
#pragma mark Override

- (void)setEstimatedArrivalWindowBeginWithNSString:(NSString *)estimatedArrivalWindowBeginString {
    self.estimatedArrivalWindowBegin = [NestSDKUtils dateWithISO8601FormatDateString:estimatedArrivalWindowBeginString];
}

- (id)JSONObjectForEstimatedArrivalWindowBegin {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.estimatedArrivalWindowBegin];
}

- (void)setEstimatedArrivalWindowEndWithNSString:(NSString *)estimatedArrivalWindowEndString {
    self.estimatedArrivalWindowEnd = [NestSDKUtils dateWithISO8601FormatDateString:estimatedArrivalWindowEndString];
}

- (id)JSONObjectForEstimatedArrivalWindowEnd {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.estimatedArrivalWindowEnd];
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKETADataModel *etaDataModelCopy = (NestSDKETADataModel *) copy;
    etaDataModelCopy.tripId = self.tripId;
    etaDataModelCopy.estimatedArrivalWindowBegin = self.estimatedArrivalWindowBegin;
    etaDataModelCopy.estimatedArrivalWindowEnd = self.estimatedArrivalWindowEnd;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + self.tripId.hash;
    result = prime * result + self.estimatedArrivalWindowBegin.hash;
    result = prime * result + self.estimatedArrivalWindowEnd.hash;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    NestSDKETADataModel *otherEta = (NestSDKETADataModel *) other;
    return (([NestSDKUtils object:self.tripId isEqualToObject:otherEta.tripId]) &&
            ([NestSDKUtils object:self.estimatedArrivalWindowBegin isEqualToObject:otherEta.estimatedArrivalWindowBegin]) &&
            ([NestSDKUtils object:self.estimatedArrivalWindowEnd isEqualToObject:otherEta.estimatedArrivalWindowEnd]));
}

@end