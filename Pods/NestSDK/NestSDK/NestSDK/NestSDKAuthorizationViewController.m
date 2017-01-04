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

#import "NestSDKAuthorizationViewController.h"
#import "UIColor+NestBlue.h"
#import "NestSDKError.h"
#import "NestSDKUtils.h"

#pragma mark const

static const int kNavigationBarHeight = 64;

static NSString *const kTitleStringConnectWithNest = @"Connect With Nest";

static NSString *const kURLParameterState = @"state";
static NSString *const kURLParameterCode = @"code";

static NSString *const kArgumentAuthorizationURL = @"authorizationURL";
static NSString *const kArgumentRedirectURL = @"redirectURL";


@interface NestSDKAuthorizationViewController () <UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;

@end


@implementation NestSDKAuthorizationViewController
#pragma mark Initializer

- (instancetype)initWithAuthorizationURL:(NSURL *)authorizationURL
                             redirectURL:(NSURL *)redirectURL
                                delegate:(id <NestSDKAuthorizationViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSError *error;

        if (!authorizationURL) {
            error = [NestSDKError argumentRequiredErrorWithName:kArgumentAuthorizationURL message:nil];

        } else if (!redirectURL) {
            error = [NestSDKError argumentRequiredErrorWithName:kArgumentRedirectURL message:nil];
        }

        if (error) {
            [delegate viewController:self didFailWithError:error];
        }

        _delegate = delegate;
        _authorizationURL = [authorizationURL copy];
        _redirectURL = [redirectURL copy];
    }

    return self;
}

#pragma mark Private

- (void)_cancelBarButtonItemPressed:(id)sender {
    [self.delegate viewControllerDidCancel:self];
}

#pragma mark Override

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Add a navigation bar to the top
    CGRect navigationBarFrame = CGRectMake(0, 0, self.view.frame.size.width, kNavigationBarHeight);

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:navigationBarFrame];
    [self.view addSubview:navigationBar];

    // Add some items to the navigation bar
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(_cancelBarButtonItemPressed:)];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:kTitleStringConnectWithNest];
    navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    [navigationBar pushNavigationItem:navigationItem animated:YES];

    // Add a UIWebView to take up the entire view (beneath the navigation bar)
    CGRect webViewFrame = CGRectMake(0, kNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - kNavigationBarHeight);

    self.webView = [[UIWebView alloc] initWithFrame:webViewFrame];
    self.webView.backgroundColor = [UIColor nestBlue];
    self.webView.delegate = self;

    [self.view addSubview:self.webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the title
    self.title = kTitleStringConnectWithNest;

    // Load the URL in the web view
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.authorizationURL]];
}

#pragma mark Delegate UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    
    if ([[url host] isEqualToString:[self.redirectURL host]]) {
        NSDictionary *authorizationURLParametersDictionary = [NestSDKUtils queryParametersDictionaryFromQueryString:[self.authorizationURL query]];
        NSDictionary *redirectURLParametersDictionary = [NestSDKUtils queryParametersDictionaryFromQueryString:[url query]];

        NSError *error;
        if (![redirectURLParametersDictionary[kURLParameterState] isEqualToString:authorizationURLParametersDictionary[kURLParameterState]]) {
            error = [NestSDKError invalidURLParameterWithName:kURLParameterState];
        }

        if (((NSString *) redirectURLParametersDictionary[kURLParameterCode]).length == 0) {
            error = [NestSDKError invalidURLParameterWithName:kURLParameterCode];
        }

        if (error) {
            [self.delegate viewController:self didFailWithError:error];

            return NO;
        }

        [self.delegate viewController:self didReceiveAuthorizationCode:redirectURLParametersDictionary[kURLParameterCode]];

        return NO;
    }

    return YES;
}


@end
