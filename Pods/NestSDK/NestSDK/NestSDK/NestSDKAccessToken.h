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

/**
 * Notification indicating that the `currentAccessToken` has changed.
 *
 * The userInfo dictionary of the notification will contain keys `NestSDKAccessTokenChangeOldKey` and `NestSDKAccessTokenChangeNewKey`.
 */
FOUNDATION_EXTERN NSString *const NestSDKAccessTokenDidChangeNotification;

FOUNDATION_EXTERN NSString *const NestSDKAccessTokenChangeNewKey;
FOUNDATION_EXTERN NSString *const NestSDKAccessTokenChangeOldKey;

/**
 * Represents an immutable access token for NestSDK.
 */
@interface NestSDKAccessToken : NSObject <NSSecureCoding>
#pragma mark Properties

/**
 * Returns the token expiration date.
 */
@property(readonly, nonatomic) NSDate *expirationDate;

/**
 * Returns the token string.
 */
@property(readonly, copy, nonatomic) NSString *tokenString;

#pragma mark Methods

/**
 * Initializes a new instance of access token.
 *
 * This initializer should only be used for advanced apps that manage tokens explicitly.
 * Typical login flows only need to use `NestSDKAuthorizationManager` along with `+currentAccessToken`.
 *
 * @param tokenString The token string.
 * @param expirationDate The token expiration date.
 */
- (instancetype)initWithTokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate NS_DESIGNATED_INITIALIZER;

/**
 * Compares the receiver to another FBSDKAccessToken
 *
 * @param token Another access token
 * @return YES if the receiver's values are equal to the other token's values; otherwise NO
 */
- (BOOL)isEqualToAccessToken:(NestSDKAccessToken *)token;

/**
 * Returns the global access token that represents the currently logged in user.
 *
 * The `currentAccessToken` is a convenient representation of the token of the
 * current user and is used by other SDK components (like `NestSDKAuthorizationManager`).
 */
+ (NestSDKAccessToken *)currentAccessToken;

/**
 * Sets the global access token that represents the currently logged in user.
 * This will broadcast a notification and save the token to the app keychain.
 *
 * @param token The access token to set.
 */
+ (void)setCurrentAccessToken:(NestSDKAccessToken *)token;


@end