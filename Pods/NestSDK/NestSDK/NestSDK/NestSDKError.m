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

#import "NestSDKError.h"

#pragma mark const

NSString *const NestSDKErrorDomain = @"NestSDKErrorDomain";

static NSString *const kErrorDescriptionStingArgumentRequired = @"Method argument required error!";
static NSString *const kErrorDescriptionStingMainBundleKeyRequired = @"Main bundle key is required error!";
static NSString *const kErrorDescriptionStingBadResponse = @"Bad response received error!";
static NSString *const kErrorDescriptionStingUnexpectedType = @"Unexpected type of argument error!";
static NSString *const kErrorDescriptionStingUnableToParseData = @"Unable to parse data error!";
static NSString *const kErrorDescriptionStingInvalidURLParameter = @"Invalid URL parameter!";

static NSString *const kErrorFailureReasonStingArgumentRequired = @"Value for '%@' is required.";
static NSString *const kErrorFailureReasonStingMainBundleKeyRequired = @"'%@' key in main bundle is required.";
static NSString *const kErrorFailureReasonStingBadResponse = @"Received wrong status code: %ld";
static NSString *const kErrorFailureReasonStingUnexpectedType = @"Argument '%@' has unexpected type.";
static NSString *const kErrorFailureReasonStingInvalidURLParameter = @"There is invalid parameter '%@' in your redirect URL.";

static NSString *const kErrorRecoverySuggestionStingMainBundleKeyRequired = @"Check '%@' key is set in your info.plist file.";


@implementation NestSDKError
#pragma mark Public

+ (NSString *)errorDomain {
    return NestSDKErrorDomain;
}

+ (NSError *)errorWithCode:(NSInteger)code
               description:(NSString *)description
             failureReason:(NSString *)failureReason
        recoverySuggestion:(NSString *)recoverySuggestion
           underlyingError:(NSError *)underlyingError {

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[NSLocalizedDescriptionKey] = description;
    userInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
    userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion;
    userInfo[NSUnderlyingErrorKey] = underlyingError;

    return [[NSError alloc] initWithDomain:[self errorDomain] code:code userInfo:userInfo];
}

+ (NSError *)argumentRequiredErrorWithName:(NSString *)name message:(NSString *)message {
    return [self errorWithCode:NestSDKErrorCodeArgumentRequired
                   description:kErrorDescriptionStingArgumentRequired
                 failureReason:[NSString stringWithFormat:kErrorFailureReasonStingArgumentRequired, name]
            recoverySuggestion:nil
               underlyingError:nil];
}


+ (NSError *)mainBundleKeyRequiredErrorWithKey:(NSString *)key message:(NSString *)message {
    return [self errorWithCode:NestSDKErrorCodeMainBundleKeyRequired
                   description:kErrorDescriptionStingMainBundleKeyRequired
                 failureReason:[NSString stringWithFormat:kErrorFailureReasonStingMainBundleKeyRequired, key]
            recoverySuggestion:[NSString stringWithFormat:kErrorRecoverySuggestionStingMainBundleKeyRequired, key]
               underlyingError:nil];
}

+ (NSError *)badResponseErrorWithStatusCode:(NSInteger)statusCode message:(NSString *)message {
    return [self errorWithCode:NestSDKErrorCodeBadResponse
                   description:kErrorDescriptionStingBadResponse
                 failureReason:[NSString stringWithFormat:kErrorFailureReasonStingBadResponse, (long)statusCode]
            recoverySuggestion:nil
               underlyingError:nil];
}

+ (NSError *)unexpectedArgumentTypeErrorWithName:(NSString *)name message:(NSString *)message {

    return [self errorWithCode:NestSDKErrorCodeUnexpectedArgumentType
                   description:kErrorDescriptionStingUnexpectedType
                 failureReason:[NSString stringWithFormat:kErrorFailureReasonStingUnexpectedType, name]
            recoverySuggestion:nil
               underlyingError:nil];
}

+ (NSError *)unableToParseDataErrorWithUnderlyingError:(NSError *)error {
    return [self errorWithCode:NestSDKErrorCodeUnableToParseData
                   description:kErrorDescriptionStingUnableToParseData
                 failureReason:nil
            recoverySuggestion:nil
               underlyingError:error];
}

+ (NSError *)invalidURLParameterWithName:(NSString *)name {
    return [self errorWithCode:NestSDKErrorCodeInvalidURLParameter
                   description:kErrorDescriptionStingInvalidURLParameter
                 failureReason:[NSString stringWithFormat:kErrorFailureReasonStingInvalidURLParameter, name]
            recoverySuggestion:nil
               underlyingError:nil];
}

@end