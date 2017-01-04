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
#import <NestSDK/NestSDKProductIdentification.h>
#import "NestSDKDataModel.h"

@protocol Optional;

/**
 * An object containing the device and serial number identifiers for the product.
 */
@interface NestSDKProductIdentificationDataModel : NestSDKDataModel <NestSDKProductIdentification>
#pragma mark Properties

/**
 * Unique device identifier for the product, used in the Resource use API.
 *
 * Learn more about Resource use API https://developer.nest.com/documentation/cloud/resource-use-guide
 */
@property(nonatomic, copy) NSString <Optional> *deviceId;

/**
 * Serial number of the product or device, used in the Resource use API. Must be unique within company and product type path.
 *
 * Learn more about Resource use API https://developer.nest.com/documentation/cloud/resource-use-guide
 */
@property(nonatomic, copy) NSString <Optional> *serialNumber;

@end