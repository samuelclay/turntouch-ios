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

#import "NestSDKCameraLastEventDataModel.h"
#import "NestSDKUtils.h"


@implementation NestSDKCameraLastEventDataModel
#pragma mark Override

- (void)setStartTimeWithNSString:(NSString *)startTimeString {
    self.startTime = [NestSDKUtils dateWithISO8601FormatDateString:startTimeString];
}

- (id)JSONObjectForStartTime {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.startTime];
}

- (void)setEndTimeWithNSString:(NSString *)endTimeString {
    self.endTime = [NestSDKUtils dateWithISO8601FormatDateString:endTimeString];
}

- (id)JSONObjectForEndTime {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.endTime];
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKCameraLastEventDataModel *cameraLastEventDataModelCopy = (NestSDKCameraLastEventDataModel *) copy;
    cameraLastEventDataModelCopy.hasSound = self.hasSound;
    cameraLastEventDataModelCopy.hasMotion = self.hasMotion;
    cameraLastEventDataModelCopy.startTime = self.startTime;
    cameraLastEventDataModelCopy.endTime = self.endTime;
    cameraLastEventDataModelCopy.webUrl = self.webUrl;
    cameraLastEventDataModelCopy.appUrl = self.appUrl;
    cameraLastEventDataModelCopy.imageUrl = self.imageUrl;
    cameraLastEventDataModelCopy.animatedImageUrl = self.animatedImageUrl;
}

- (NSUInteger)hash {
    NSUInteger intValueForYes = 1231;
    NSUInteger intValueForNo = 1237;

    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + (self.hasSound ? intValueForYes : intValueForNo);
    result = prime * result + (self.hasMotion ? intValueForYes : intValueForNo);
    result = prime * result + self.startTime.hash;
    result = prime * result + self.endTime.hash;
    result = prime * result + self.webUrl.hash;
    result = prime * result + self.appUrl.hash;
    result = prime * result + self.imageUrl.hash;
    result = prime * result + self.animatedImageUrl.hash;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    NestSDKCameraLastEventDataModel *otherCamera = (NestSDKCameraLastEventDataModel *) other;
    return ((self.hasSound == otherCamera.hasSound) &&
            (self.hasMotion == otherCamera.hasMotion) &&
            ([NestSDKUtils object:self.startTime isEqualToObject:otherCamera.startTime]) &&
            ([NestSDKUtils object:self.endTime isEqualToObject:otherCamera.endTime]) &&
            ([NestSDKUtils object:self.webUrl isEqualToObject:otherCamera.webUrl]) &&
            ([NestSDKUtils object:self.appUrl isEqualToObject:otherCamera.appUrl]) &&
            ([NestSDKUtils object:self.imageUrl isEqualToObject:otherCamera.imageUrl]) &&
            ([NestSDKUtils object:self.animatedImageUrl isEqualToObject:otherCamera.animatedImageUrl]));
}
@end