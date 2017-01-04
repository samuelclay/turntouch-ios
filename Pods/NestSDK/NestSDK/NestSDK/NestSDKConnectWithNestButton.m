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

#import "NestSDKConnectWithNestButton.h"
#import "NestSDKAuthorizationManager.h"
#import "UIColor+NestBlue.h"
#import "NestSDKAccessToken.h"
#import "NestSDKUtils.h"


#pragma mark const

static const int kDefaultFontSize = 16;

static const int kDefaultWidth = 200;
static const int kDefaultHeight = 32;

static const int kActionSheetButtonIndexDisconnect = 0;

static const int kDefaultCornerRadius = 6;

static NSString *const kStringConnectWithNest = @"Connect with Nest";
static NSString *const kStringDisconnect = @"Disconnect";
static NSString *const kStringDisconnectFromNest = @"Disconnect from Nest";

static NSString *const kStringCancel = @"Cancel";

@interface NestSDKConnectWithNestButton ()

@property(nonatomic, strong) NestSDKAuthorizationManager *authorizationManager;

@end


@implementation NestSDKConnectWithNestButton
#pragma mark Initializer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _configureWithFrame:frame];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [self _configureWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)];
}

#pragma mark Private

- (void)_configureWithFrame:(CGRect)frame {
    self.authorizationManager = [[NestSDKAuthorizationManager alloc] init];

    self.frame = frame;

    [self _configureAppearance];
    [self _updateButtonState];

    [self _addButtonPressedAction];
    [self _addAccessTokenChangeObserver];
}

- (void)_addButtonPressedAction {
    [self addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_addAccessTokenChangeObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenDidChangeNotification:)
                                                 name:NestSDKAccessTokenDidChangeNotification
                                               object:nil];
}

- (void)_removeAccessTokenChangeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_configureAppearance {
    [self _configureImageAdjustments];
    [self _configureAlignment];
    [self _configureTintColor];

    [self _configureLabel];
    [self _configureTitle];
    [self _configureBackground];
}

- (void)_configureImageAdjustments {
    self.adjustsImageWhenDisabled = NO;
    self.adjustsImageWhenHighlighted = NO;
}

- (void)_configureAlignment {
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
}

- (void)_configureTintColor {
    self.tintColor = [UIColor whiteColor];
}

- (void)_configureLabel {
    UILabel *titleLabel = self.titleLabel;
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UIFont *font = [UIFont boldSystemFontOfSize:kDefaultFontSize];
    titleLabel.font = font;
}

- (void)_configureTitle {
    [self _setTitleColor];

    [self _setTitleForNormalState];
    [self _setTitleForSelectedState];
    [self _setTitleForHighlightedState];
}

- (void)_setTitleColor {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)_setTitleForNormalState {
    [self setTitle:self.selected ? kStringDisconnect : kStringConnectWithNest forState:UIControlStateNormal];
//    [self setTitle:kStringConnectWithNest forState:UIControlStateNormal];
}

- (void)_setTitleForSelectedState {
    [self setTitle:kStringDisconnect forState:UIControlStateSelected];
}

- (void)_setTitleForHighlightedState {
    [self setTitle:self.selected ? kStringDisconnect : kStringConnectWithNest forState:UIControlStateHighlighted];
}

- (void)_configureBackground {
    [self _setBackgroundImageWithColor:[UIColor nestBlue] forState:UIControlStateNormal];
    [self _setBackgroundImageWithColor:[UIColor nestBlueSelected] forState:UIControlStateHighlighted];
    [self _setBackgroundImageWithColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self _setBackgroundImageWithColor:[UIColor nestBlueSelected] forState:UIControlStateSelected];
}

- (void)_setBackgroundImageWithColor:(UIColor *)color forState:(UIControlState)state {
    UIImage *backgroundImage = [self _backgroundImageWithColor:color];

    [self setBackgroundImage:backgroundImage forState:state];
}

- (UIImage *)_backgroundImageWithColor:(UIColor *)color {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *backgroundImage = [NestSDKUtils imageWithColor:color cornerRadius:kDefaultCornerRadius scale:scale];

    return backgroundImage;
}

- (void)_updateButtonState {
    self.selected = ([NestSDKAccessToken currentAccessToken] != nil);
}

- (void)_accessTokenDidChangeNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self _updateButtonState];
    });
}

- (void)_buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(connectWithNestButtonWillAuthorize:)]) {
        if (![self.delegate connectWithNestButtonWillAuthorize:self]) return;
    }

    if ([NestSDKAccessToken currentAccessToken]) {
        [self _showConfirmDisconnectActionSheet];

    } else {
        [self _authorize];
    }
}

- (void)_showConfirmDisconnectActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:kStringCancel
                                         destructiveButtonTitle:kStringDisconnectFromNest
                                              otherButtonTitles:nil];
    [sheet showInView:self];
}

- (void)_authorize {
    __weak typeof(self) weakSelf = self;
    NestSDKAuthorizationManagerAuthorizationHandler handler = ^(NestSDKAuthorizationManagerAuthorizationResult *result, NSError *error) {
        typeof(self) self = weakSelf;
        if (!self) return;

        if ([self.delegate respondsToSelector:@selector(connectWithNestButton:didAuthorizeWithResult:error:)]) {
            [self.delegate connectWithNestButton:self didAuthorizeWithResult:result error:error];
        }
    };

    [self.authorizationManager authorizeWithNestAccountFromViewController:[NestSDKUtils viewControllerForView:self] handler:handler];
}

#pragma mark Override

- (void)prepareForInterfaceBuilder {
    [self _setTitleForNormalState];
    [self _setBackgroundImageWithColor:[UIColor nestBlue] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self _setTitleForNormalState];
    [self _setTitleForHighlightedState];
}

- (void)dealloc {
    [self _removeAccessTokenChangeObserver];
}

#pragma mark Delegate UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == kActionSheetButtonIndexDisconnect) {
        [self.authorizationManager unauthorize];

        [self.delegate connectWithNestButtonDidUnauthorize:self];
    }
}

@end