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
#import <UIKit/UIKit.h>
#import "NestSDKAuthorizationViewController.h"

@class NestSDKAuthorizationManagerAuthorizationResult;

#pragma mark typedef

/**
 * Describes the call back to the NestSDKAuthorizationManager
 *
 * @param result the result of the authorization
 * @param error the authorization error, if any.
 */
typedef void (^NestSDKAuthorizationManagerAuthorizationHandler)(NestSDKAuthorizationManagerAuthorizationResult *result, NSError *error);

/**
 * Provides methods for authorizing and unauthorizing the user.
 * `NestSDKAuthorizationManager` works directly with `[NestSDKAccessToken currentAccessToken]`
 * and sets the `currentAccessToken` upon successful authorizations (or sets nil in case of unauthorization).
 *
 * You should check `[NestSDKAccessToken currentAccessToken]` before calling authorize to see if there is
 * a cached token available (typically in your `viewDidLoad`).
 *
 * If you are managing your own token instances outside of `currentAccessToken`, you will need to set
 * `currentAccessToken` before calling authorize.
 */
@interface NestSDKAuthorizationManager : NSObject <NestSDKAuthorizationViewControllerDelegate>
#pragma mark Methods

/**
 * Authorizes the user.
 *
 * This method will present UI the user. You typically should check if [NestSDKAccessToken currentAccessToken]
 * before calling this method. For example, you could make that check at viewDidLoad.
 *
 * @param viewController the view controller to present from.
 * @param handler the callback.
 */
- (void)authorizeWithNestAccountFromViewController:(UIViewController *)viewController
                                           handler:(NestSDKAuthorizationManagerAuthorizationHandler)handler;

/**
 * Unauthorizes the user.
 *
 * This calls [NestSDKAccessToken setCurrentAccessToken:nil]
 */
- (void)unauthorize;

@end