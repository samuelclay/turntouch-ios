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
#import <NestSDK/NestSDKService.h>

@class NestSDKAccessToken;

#pragma mark typedef

/**
 * Describes the result of service authentication request.
 */
typedef void (^NestSDKAuthenticableServiceCompletionBlock)(NSError *error);

/**
 * Protocol for authenticable NestSDK service. Each NestSDK service should conform this protocol.
 */
@protocol NestSDKAuthenticableService <NestSDKService>
#pragma mark Methods

/**
 * Authenticates current service instance with provided AccessToken.
 *
 * @param accessToken The access token to authenticate service instance with.
 * @param completionBlock The block called when authentication has completed or failed. In case of failure returns error.
 */
- (void)authenticateWithAccessToken:(NestSDKAccessToken *)accessToken
                    completionBlock:(NestSDKAuthenticableServiceCompletionBlock)completionBlock;

/**
 * Unauthenticates current service.
 */
- (void)unauthenticate;

@end