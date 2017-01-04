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
#import <NestSDK/NestSDKProduct.h>
#import "NestSDKDataModel.h"
#import "NestSDKProductIdentificationDataModel.h"
#import "NestSDKProductLocationDataModel.h"
#import "NestSDKProductSoftwareDataModel.h"
#import "NestSDKProductResourceUseDataModel.h"

@class NestSDKProductIdentificationDataModel;
@class NestSDKProductLocationDataModel;
@class NestSDKProductSoftwareDataModel;
@class NestSDKProductResourceUseDataModel;

/**
 * An object containing product type information.
 *
 * Use this object with the Resource use API to share the product's resource use data (electricity, water, or gas) with Nest.
 *
 * Learn more about Resource use API https://developer.nest.com/documentation/cloud/resource-use-guide
 */
@interface NestSDKProductDataModel : NestSDKDataModel <NestSDKProduct>
#pragma mark Properties

/**
 * An object containing the device and serial number identifiers for the product.
 */
@property(nonatomic) NestSDKProductIdentificationDataModel <Optional> *identification;

/**
 * An object containing the structure identifier.
 */
@property(nonatomic) NestSDKProductLocationDataModel <Optional> *location;

/**
 * An object containing the software version identifier for your product.
 */
@property(nonatomic) NestSDKProductSoftwareDataModel <Optional> *software;

/**
 * An object containing the resource use type (electricity, gas, water), with data values and measurement timestamps.
 */
@property(nonatomic) NestSDKProductResourceUseDataModel <Optional> *resourceUse;

@end