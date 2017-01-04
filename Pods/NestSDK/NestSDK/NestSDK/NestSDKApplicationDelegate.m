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

#import <Firebase/Firebase.h>
#import "NestSDKApplicationDelegate.h"
#import "NestSDKAccessToken.h"
#import "NestSDKAccessTokenCache.h"
#import "NestSDKService.h"
#import "NestSDKRESTService.h"
#import "NestSDKFirebaseService.h"
#import "NestSDKLogger.h"

static NSString *const kNestAPIEndpointURLString = @"https://developer-api.nest.com/";

static id <NestSDKService> g_service;


@interface NestSDKApplicationDelegate ()
// For future use
@property(nonatomic) BOOL useRESTService;

@end


@implementation NestSDKApplicationDelegate
#pragma mark Private

- (id <NestSDKAuthenticableService>)_service {
    return (id <NestSDKAuthenticableService>) g_service;
}

- (void)_setService:(id <NestSDKAuthenticableService>)service {
    g_service = service;
}

- (void)_initLogger {
#if (DEBUG)
    // By default notify user about errors only and only in debug
    [NestSDKLogger setLogLevel:NestSDKLoggerLogLevelError];
#else
    // Do not log anything to TTY in production
    [NestSDKLogger setLogLevel:NestSDKLoggerLogLevelNone];
#endif
}

- (void)_restoreCachedAccessToken {
    // Restoring cached token
    NestSDKAccessTokenCache *accessTokenCache = [[NestSDKAccessTokenCache alloc] init];
    NestSDKAccessToken *cachedToken = [accessTokenCache fetchAccessToken];

    // If expired then remove token
    if (!cachedToken || [[cachedToken expirationDate] compare:[NSDate date]] == NSOrderedAscending) {
        [accessTokenCache clearCache];

    } else {
        [NestSDKAccessToken setCurrentAccessToken:cachedToken];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenDidChangeNotification:)
                                                 name:NestSDKAccessTokenDidChangeNotification
                                               object:nil];
}

- (void)_initService {
    id <NestSDKAuthenticableService> service;

    if (self.useRESTService) {
        service = [[NestSDKRESTService alloc] init];

    } else {
        Firebase *firebase = [[Firebase alloc] initWithUrl:kNestAPIEndpointURLString];
        service = [[NestSDKFirebaseService alloc] initWithFirebase:firebase];
    }

    [self _setService:service];

    if ([NestSDKAccessToken currentAccessToken]) {
        [self _authenticateServiceWithAccessToken:[NestSDKAccessToken currentAccessToken]];
    }
}

- (void)_removeService {
    [[self _service] unauthenticate];
    [self _setService:nil];
}

- (void)_authenticateServiceWithAccessToken:(NestSDKAccessToken *)accessToken {
    [[self _service] authenticateWithAccessToken:accessToken completionBlock:^(NSError *error) {
        if (error) {
            // Something went wrong
            [NestSDKLogger logError:@"Authentication failed!" withErorr:error from:self];

            // Remove current access token expecting that renewed access token will fix the problem
            [NestSDKAccessToken setCurrentAccessToken:nil];

        } else {
            [NestSDKLogger logInfo:@"Authentication successful!" from:self];
        }
    }];
}

- (void)_accessTokenDidChangeNotification:(NSNotification *)notification {
    NestSDKAccessToken *accessToken = notification.userInfo[NestSDKAccessTokenChangeNewKey];

    // If access token has changed, then re-authenticate service
    if (accessToken) {
        if ([self _service]) {
            [self _authenticateServiceWithAccessToken:[NestSDKAccessToken currentAccessToken]];

            // If there is no service, then recreate it
        } else {
            [self _initService];
        }

        // If token was removed, then remove the service
    } else {
        [self _removeService];
    }
}

#pragma mark Public

+ (instancetype)sharedInstance {
    static NestSDKApplicationDelegate *_sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self _initLogger];

    [self _restoreCachedAccessToken];
    [self _initService];

    return NO;
}

+ (id <NestSDKService>)service {
    return g_service;
}

@end