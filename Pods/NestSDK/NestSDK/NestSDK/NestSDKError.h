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

#pragma mark const

FOUNDATION_EXTERN NSString *const NestSDKErrorDomain;

#pragma mark typedef

/**
 * Error codes for NestSDKErrorDomain
 */
typedef NS_ENUM(NSInteger, NestSDKErrorCode) {
    /**
     *  Undefined.
     */
            NestSDKErrorCodeUnefined = 0,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeArgumentRequired,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeInvalidURLParameter,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeMainBundleKeyRequired,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeBadResponse,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeUnexpectedArgumentType,

    /**
     * The error code for errors from invalid arguments to SDK methods.
     */
            NestSDKErrorCodeUnableToParseData
};

/**
 * Class representing errors for NestSDK
 */
@interface NestSDKError : NSObject
#pragma mark Methods

+ (NSError *)argumentRequiredErrorWithName:(NSString *)name message:(NSString *)message;

+ (NSError *)mainBundleKeyRequiredErrorWithKey:(NSString *)key message:(NSString *)message;

+ (NSError *)badResponseErrorWithStatusCode:(NSInteger)statusCode message:(NSString *)message;

+ (NSError *)unexpectedArgumentTypeErrorWithName:(NSString *)name message:(NSString *)message;

+ (NSError *)unableToParseDataErrorWithUnderlyingError:(NSError *)error;

+ (NSError *)invalidURLParameterWithName:(NSString *)name;

@end