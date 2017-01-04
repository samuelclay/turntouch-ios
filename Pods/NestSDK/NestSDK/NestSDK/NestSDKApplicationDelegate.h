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
#import <UIKit/UIApplication.h>

@protocol NestSDKService;

/**
 * NestSDKApplicationDelegate is a main connection point with Nest SDK.
 * It is designed to be able process the results from Nest authorization dialogs (native app or Safari) in the future.
 */
@interface NestSDKApplicationDelegate : NSObject
#pragma mark Methods

/**
 * Gets the singleton instance.
 */
+ (instancetype)sharedInstance;

+ (id <NestSDKService>)service;

/**
 * Call this method from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
 * of the AppDelegate for your app. It should be invoked for the proper processing of responses during interaction
 * with the native app or Safari as part of SSO authorization flow in the future.
 *
 * @param application The application as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param url The URL as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param sourceApplication The sourceApplication as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 * @param annotation The annotation as passed to [UIApplicationDelegate application:openURL:sourceApplication:annotation:].
 *
 * @return NO in any case for now.
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

/**
 * Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
 * of the AppDelegate for your app. It should be invoked for the proper use of the Nest SDK in the future.
 *
 * @param application The application as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
 * @param launchOptions The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
 *
 * @return NO in any case for now.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end