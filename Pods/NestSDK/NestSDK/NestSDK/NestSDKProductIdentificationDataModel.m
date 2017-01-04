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

#import "NestSDKProductIdentificationDataModel.h"
#import "NestSDKUtils.h"

@implementation NestSDKProductIdentificationDataModel
#pragma mark Override

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
    [super copyPropertiesToDataModelCopy:copy];

    NestSDKProductIdentificationDataModel *productIdentificationDataModelCopy = (NestSDKProductIdentificationDataModel *) copy;
    productIdentificationDataModelCopy.deviceId = self.deviceId;
    productIdentificationDataModelCopy.serialNumber = self.serialNumber;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + self.deviceId.hash;
    result = prime * result + self.serialNumber.hash;

    return result;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;

    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    NestSDKProductIdentificationDataModel *otherProductIdentification = (NestSDKProductIdentificationDataModel *) other;
    return (([NestSDKUtils object:self.deviceId isEqualToObject:otherProductIdentification.deviceId]) &&
            ([NestSDKUtils object:self.serialNumber isEqualToObject:otherProductIdentification.serialNumber]));
}

@end