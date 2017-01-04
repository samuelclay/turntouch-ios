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

#pragma mark typedef
typedef NS_ENUM(NSUInteger, NestSDKLoggerLogLevel) {
    NestSDKLoggerLogLevelNone = 0,
    NestSDKLoggerLogLevelError,
    NestSDKLoggerLogLevelWarning,
    NestSDKLoggerLogLevelInfo,
    NestSDKLoggerLogLevelDebug
};

/**
 * Simple logger used to inform user about errors happen inside NestSDK and to debug NestSDK workflow.
 */
@interface NestSDKLogger : NSObject
#pragma mark Methods

+ (void)logDebug:(NSString *)message from:(id)from;

+ (void)logInfo:(NSString *)message from:(id)from;

+ (void)logWarn:(NSString *)message from:(id)from;

+ (void)logError:(NSString *)message withErorr:(NSError *)error from:(id)from;

+ (NestSDKLoggerLogLevel)logLevel;

+ (void)setLogLevel:(NestSDKLoggerLogLevel)logLevel;

@end