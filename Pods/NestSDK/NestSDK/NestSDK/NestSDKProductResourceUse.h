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
#import <NestSDK/NestSDKProductResource.h>
#import <NestSDK/NestSDKDataModelProtocol.h>

/**
 * Protocol for Nest product resource use data model.
 *
 * An object containing the resource use type (electricity, gas, water), with data values and measurement timestamps.
 */
@protocol NestSDKProductResourceUse <NestSDKDataModelProtocol>
#pragma mark Properties

/**
 * An object that contains electricity data for the product type.
 */
@property(nonatomic, readonly) id <NestSDKProductResource> electricity;

/**
 * An object that contains gas data for the product type.
 */
@property(nonatomic, readonly) id <NestSDKProductResource> gas;

/**
 * An object that contains water data for the product type.
 */
@property(nonatomic, readonly) id <NestSDKProductResource> water;

@end