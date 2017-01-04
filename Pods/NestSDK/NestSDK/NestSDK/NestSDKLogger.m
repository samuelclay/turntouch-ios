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

#import "NestSDKLogger.h"

static NestSDKLoggerLogLevel g_logLevel;


@implementation NestSDKLogger
#pragma mark Public

+ (void)logError:(NSString *)message withErorr:(NSError *)error from:(id)from {
    if (g_logLevel >= NestSDKLoggerLogLevelError) {
        NSLog(@"%@ Error: %@", message, error);
    }
}

+ (void)logWarn:(NSString *)message from:(id)from {
    if (g_logLevel >= NestSDKLoggerLogLevelWarning) {
        NSLog(@"%@", message);
    }
}

+ (void)logInfo:(NSString *)message from:(id)from {
    if (g_logLevel >= NestSDKLoggerLogLevelInfo) {
        NSLog(@"%@", message);
    }
}

+ (void)logDebug:(NSString *)message from:(id)from {
    if (g_logLevel >= NestSDKLoggerLogLevelDebug) {
        NSLog(@"%@", message);
    }
}

+ (NestSDKLoggerLogLevel)logLevel {
    return g_logLevel;
}

+ (void)setLogLevel:(NestSDKLoggerLogLevel)logLevel {
    g_logLevel = logLevel;
}

@end