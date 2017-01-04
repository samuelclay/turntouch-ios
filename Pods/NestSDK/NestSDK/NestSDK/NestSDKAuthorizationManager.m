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

#import <libkern/OSAtomic.h>
#import "NestSDKAuthorizationManager.h"
#import "NestSDKAuthorizationManagerAuthorizationResult.h"
#import "NestSDKAccessToken.h"
#import "NestSDKError.h"

#pragma mark const

static NSString *const kNestOAuthDomainString = @"home.nest.com";

static NSString *const kNestProductIDKey = @"NestProductID";
static NSString *const kNestProductSecretKey = @"NestProductSecret";
static NSString *const kNestRedirectURLKey = @"NestRedirectURL";

static NSString *const kNestAuthorizationURLFormat = @"https://%@/login/oauth2?client_id=%@&state=%@";
static NSString *const kNestAccessTokenURLFormat = @"https://api.%@/oauth2/access_token?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code";

static NSString *const kJSONKeyAccessToken = @"access_token";
static NSString *const kJSONKeyExpiresIn = @"expires_in";

static NSString *const KHTTPHeaderKeyContentType = @"Content-Type";
static NSString *const kHeaderValueFormData = @"form-data";

static NSString *const kHTTPMethodPost = @"POST";

static const Byte kHTTPStatusCodeOK = 200;
static const NSTimeInterval kDefaultTimeoutInterval = 8.0;


@interface NestSDKAuthorizationManager ()

@property(nonatomic) NestSDKAuthorizationViewController *authorizationViewController;
@property(nonatomic, copy) NestSDKAuthorizationManagerAuthorizationHandler handler;

@end


@implementation NestSDKAuthorizationManager
#pragma mark Private

- (NSString *)_state {
    // Each request generate unique state string based on bundle identifier of the app and UUID string
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return [bundleIdentifier stringByAppendingFormat:@"_%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)_productID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:kNestProductIDKey];
}

- (NSString *)_productSecret {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:kNestProductSecretKey];
}

- (NSURL *)_redirectURL {
    NSString *urlString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kNestRedirectURLKey];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)_authorizationURL {
    NSString *urlString = [NSString stringWithFormat:kNestAuthorizationURLFormat, kNestOAuthDomainString, [self _productID], [self _state]];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)_accessTokenURLWithAuthorizationCode:(NSString *)authorizationCode {
    NSString *urlString = [NSString stringWithFormat:kNestAccessTokenURLFormat, kNestOAuthDomainString, authorizationCode, [self _productID], [self _productSecret]];
    return [NSURL URLWithString:urlString];
}

- (NestSDKAuthorizationManagerAuthorizationResult *)_authorizationResultWithData:(NSData *)data error:(NSError **)error {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (*error) return nil;

    NSString *tokenString = json[kJSONKeyAccessToken];
    NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:[json[kJSONKeyExpiresIn] longValue]];

    NestSDKAccessToken *accessToken = [[NestSDKAccessToken alloc] initWithTokenString:tokenString expirationDate:expirationDate];

    return [[NestSDKAuthorizationManagerAuthorizationResult alloc] initWithToken:accessToken isCancelled:NO];
}

- (void)_obtainTokenWithAuthorizationCode:(NSString *)authorizationCode {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self _accessTokenURLWithAuthorizationCode:authorizationCode]];
    [request setHTTPMethod:kHTTPMethodPost];
    [request setValue:kHeaderValueFormData forHTTPHeaderField:KHTTPHeaderKeyContentType];

    NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    urlSessionConfiguration.allowsCellularAccess = YES;
    urlSessionConfiguration.timeoutIntervalForRequest = kDefaultTimeoutInterval;
    urlSessionConfiguration.timeoutIntervalForResource = kDefaultTimeoutInterval;

    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:nil];

    __weak typeof(self)weakSelf = self;
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       typeof(self) self = weakSelf;
                                                       if (!self) return;

                                                       if (error) {
                                                           [self _finishAuthorizationWithAuthorizationResult:nil error:error];

                                                           return;
                                                       }

                                                       NSInteger responseStatusCode = ((NSHTTPURLResponse *) response).statusCode;
                                                       if (responseStatusCode != kHTTPStatusCodeOK) {
                                                           NSError *badResponseError = [NestSDKError badResponseErrorWithStatusCode:responseStatusCode message:nil];
                                                           [self _finishAuthorizationWithAuthorizationResult:nil error:badResponseError];

                                                           return;
                                                       }

                                                       NestSDKAuthorizationManagerAuthorizationResult *authorizationResult = [self _authorizationResultWithData:data error:&error];
                                                       if (error) {
                                                           [self _finishAuthorizationWithAuthorizationResult:nil error:error];

                                                           return;
                                                       }

                                                       [NestSDKAccessToken setCurrentAccessToken:authorizationResult.token];

                                                       [self _finishAuthorizationWithAuthorizationResult:authorizationResult error:nil];
                                                   }];
    [dataTask resume];
}

- (void)_finishAuthorizationWithAuthorizationResult:(NestSDKAuthorizationManagerAuthorizationResult *)authorizationResult error:(NSError *)error {
    self.handler(authorizationResult, error);
    self.handler = nil;

    [self.authorizationViewController dismissViewControllerAnimated:YES completion:nil];
    self.authorizationViewController = nil;
}

#pragma mark Public

- (void)authorizeWithNestAccountFromViewController:(UIViewController *)viewController
                                           handler:(NestSDKAuthorizationManagerAuthorizationHandler)handler {
    if (!handler) return;
    
    self.handler = [handler copy];
    
    if (!viewController) {
        NSError *error = [NestSDKError argumentRequiredErrorWithName:@"viewController" message:nil];
        [self _finishAuthorizationWithAuthorizationResult:nil error:error];
        
        return;
    }

    if ([self _productID].length == 0) {
        NSError *error = [NestSDKError mainBundleKeyRequiredErrorWithKey:kNestProductIDKey message:nil];
        [self _finishAuthorizationWithAuthorizationResult:nil error:error];

        return;
    }

    if ([self _productSecret].length == 0) {
        NSError *error = [NestSDKError mainBundleKeyRequiredErrorWithKey:kNestProductSecretKey message:nil];
        [self _finishAuthorizationWithAuthorizationResult:nil error:error];

        return;
    }

    if ([self _redirectURL].absoluteString.length == 0) {
        NSError *error = [NestSDKError mainBundleKeyRequiredErrorWithKey:kNestRedirectURLKey message:nil];
        [self _finishAuthorizationWithAuthorizationResult:nil error:error];

        return;
    }
    
    self.authorizationViewController = [[NestSDKAuthorizationViewController alloc] initWithAuthorizationURL:[self _authorizationURL]
                                                                                                redirectURL:[self _redirectURL]
                                                                                                   delegate:self];

    [viewController presentViewController:_authorizationViewController animated:YES completion:nil];
}

- (void)unauthorize {
    [NestSDKAccessToken setCurrentAccessToken:nil];
}

#pragma mark NestSDKAuthorizationViewControllerDelegate

- (void)viewControllerDidCancel:(NestSDKAuthorizationViewController *)viewController {
    NestSDKAuthorizationManagerAuthorizationResult *result = [[NestSDKAuthorizationManagerAuthorizationResult alloc] initWithToken:nil isCancelled:YES];
    [self _finishAuthorizationWithAuthorizationResult:result error:nil];
}

- (void)viewController:(NestSDKAuthorizationViewController *)viewController didReceiveAuthorizationCode:(NSString *)authorizationCode {
    [self _obtainTokenWithAuthorizationCode:authorizationCode];
}

- (void)viewController:(NestSDKAuthorizationViewController *)viewController didFailWithError:(NSError *)error {
    [self _finishAuthorizationWithAuthorizationResult:nil error:error];
}

@end