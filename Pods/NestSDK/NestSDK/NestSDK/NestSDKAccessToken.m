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

#import "NestSDKAccessToken.h"
#import "NestSDKAccessTokenCache.h"

#pragma mark const

NSString *const NestSDKAccessTokenDidChangeNotification = @"NestSDK.NestSDKAccessToken.NestSDKAccessTokenDidChangeNotification";

NSString *const NestSDKAccessTokenChangeNewKey = @"NestSDKAccessToken";
NSString *const NestSDKAccessTokenChangeOldKey = @"NestSDKAccessTokenOld";

static NSString *const kExpirationDateKey = @"expirationDateKey";
static NSString *const kTokenStringKey = @"tokenStringKey";

#pragma mark static

static NestSDKAccessToken *g_currentAccessToken;


@implementation NestSDKAccessToken
#pragma mark Initializer

- (instancetype)init {
    return [self initWithTokenString:nil expirationDate:nil];
}

- (instancetype)initWithTokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate {
    self = [super init];
    if (self) {
        _tokenString = [tokenString copy];
        _expirationDate = expirationDate;
    }

    return self;
}

#pragma mark Override

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + self.tokenString.hash;
    result = prime * result + self.expirationDate.hash;

    return result;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[NestSDKAccessToken class]]) {
        return NO;
    }
    return [self isEqualToAccessToken:(NestSDKAccessToken *) object];
}

#pragma mark Public

- (BOOL)isEqualToAccessToken:(NestSDKAccessToken *)token {
    return (token &&
            [self.tokenString isEqualToString:token.tokenString] &&
            [self.expirationDate isEqualToDate:token.expirationDate]);
}

+ (NestSDKAccessToken *)currentAccessToken {
    return g_currentAccessToken;
}

+ (void)setCurrentAccessToken:(NestSDKAccessToken *)token {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[NestSDKAccessTokenChangeNewKey] = token;
    userInfo[NestSDKAccessTokenChangeOldKey] = g_currentAccessToken;

    g_currentAccessToken = token;

    [[[NestSDKAccessTokenCache alloc] init] cacheAccessToken:token];

    [[NSNotificationCenter defaultCenter] postNotificationName:NestSDKAccessTokenDidChangeNotification
                                                        object:[self class]
                                                      userInfo:userInfo];
}

#pragma mark Protocol NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Protocol NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
    NSString *tokenString = [decoder decodeObjectOfClass:[NSString class] forKey:kTokenStringKey];
    NSDate *expirationDate = [decoder decodeObjectOfClass:[NSDate class] forKey:kExpirationDateKey];

    return [self initWithTokenString:tokenString expirationDate:expirationDate];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tokenString forKey:kTokenStringKey];
    [encoder encodeObject:self.expirationDate forKey:kExpirationDateKey];
}

@end