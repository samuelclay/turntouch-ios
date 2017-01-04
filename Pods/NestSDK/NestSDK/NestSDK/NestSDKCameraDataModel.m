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

#import "NestSDKUtils.h"
#import "NestSDKCameraDataModel.h"

@implementation NestSDKCameraDataModel
#pragma mark Override

- (void)setLastIsOnlineChangeWithNSString:(NSString *)lastIsOnlineChangeString {
    self.lastIsOnlineChange = [NestSDKUtils dateWithISO8601FormatDateString:lastIsOnlineChangeString];
}

- (id)JSONObjectForLastIsOnlineChange {
    return [NestSDKUtils iso8601FormatDateStringWithDate:self.lastIsOnlineChange];
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKCameraDataModel *cameraDataModelCopy = (NestSDKCameraDataModel *) copy;
    cameraDataModelCopy.isStreaming = self.isStreaming;
    cameraDataModelCopy.isAudioInputEnabled = self.isAudioInputEnabled;
    cameraDataModelCopy.lastIsOnlineChange = self.lastIsOnlineChange;
    cameraDataModelCopy.isVideoHistoryEnabled = self.isVideoHistoryEnabled;
    cameraDataModelCopy.webUrl = self.webUrl;
    cameraDataModelCopy.appUrl = self.appUrl;
    cameraDataModelCopy.lastEvent = self.lastEvent;
}

- (NSUInteger)hash {
    NSUInteger intValueForYes = 1231;
    NSUInteger intValueForNo = 1237;

    NSUInteger prime = 31;
    NSUInteger result = [super hash];

    result = prime * result + (self.isStreaming ? intValueForYes : intValueForNo);
    result = prime * result + (self.isAudioInputEnabled ? intValueForYes : intValueForNo);
    result = prime * result + self.lastIsOnlineChange.hash;
    result = prime * result + (self.isVideoHistoryEnabled ? intValueForYes : intValueForNo);
    result = prime * result + self.webUrl.hash;
    result = prime * result + self.appUrl.hash;
    result = prime * result + self.lastEvent.hash;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    if (![super isEqual:other])
        return NO;

    NestSDKCameraDataModel *otherCamera = (NestSDKCameraDataModel *) other;
    return ((self.isStreaming == otherCamera.isStreaming) &&
            (self.isAudioInputEnabled == otherCamera.isAudioInputEnabled) &&
            ([NestSDKUtils object:self.lastIsOnlineChange isEqualToObject:otherCamera.lastIsOnlineChange]) &&
            (self.isVideoHistoryEnabled == otherCamera.isVideoHistoryEnabled) &&
            ([NestSDKUtils object:self.webUrl isEqualToObject:otherCamera.webUrl]) &&
            ([NestSDKUtils object:self.appUrl isEqualToObject:otherCamera.appUrl]) &&
            ([NestSDKUtils object:self.lastEvent isEqualToObject:otherCamera.lastEvent]));
}

@end