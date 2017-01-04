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
#import "NestSDKFirebaseService.h"
#import "NestSDKAccessToken.h"
#import "NestSDKLogger.h"
#import "NestSDKError.h"


#pragma mark const
static NSString *const kArgumentNameAccessToken = @"accessToken";


@interface NestSDKFirebaseService ()

@property(nonatomic) NSMutableDictionary *handleToURLDictionary;

@end


@implementation NestSDKFirebaseService
#pragma mark Initializer

- (instancetype)initWithFirebase:(Firebase *)firebase {
    self = [super init];
    if (self) {
        _firebase = firebase;

        self.handleToURLDictionary = [[NSMutableDictionary alloc] init];
    }

    return self;
}

#pragma mark Private

- (void)_completeAuthenticationWithBlock:(NestSDKAuthenticableServiceCompletionBlock)block error:(NSError *)error {
    if (!block) return;

    block(error);
}

- (Firebase *)_firebaseWithURL:(NSString *)url {
    if (url.length == 0) return nil;
    return [self.firebase childByAppendingPath:url];
}

#pragma mark Public

- (void)authenticateWithAccessToken:(NestSDKAccessToken *)accessToken
                    completionBlock:(NestSDKAuthenticableServiceCompletionBlock)completionBlock {
    // WARNING: Do not call unathenticate method while making re-authentication

    if (!accessToken) {
        NSError *error = [NestSDKError argumentRequiredErrorWithName:kArgumentNameAccessToken message:nil];
        [self _completeAuthenticationWithBlock:completionBlock error:error];

        return;
    }

    [NestSDKLogger logInfo:@"Authenticating..." from:self];

    __weak typeof(self) weakSelf = self;
    [self.firebase authWithCustomToken:accessToken.tokenString withCompletionBlock:^(NSError *error, FAuthData *authData) {
        typeof(self) self = weakSelf;
        if (!self) return;

        if (error) {
            [self _completeAuthenticationWithBlock:completionBlock error:error];

            return;
        }

        [self _completeAuthenticationWithBlock:completionBlock error:error];
    }];
}

- (void)unauthenticate {
    [self removeAllObservers];

    [self.firebase unauth];

    [NestSDKLogger logInfo:@"Unauthenticated!" from:self];
}

- (void)valuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {
    if (!block) return;

    Firebase *firebase = [self _firebaseWithURL:url];
    [firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        block(snapshot.value, nil);

    }                  withCancelBlock:^(NSError *error) {
        block(nil, error);
    }];
}

- (void)setValues:(NSDictionary *)values forURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {
    Firebase *firebase = [self _firebaseWithURL:url];

    // IMPORTANT to set withLocalEvents to NO.
    // More information here: https://www.firebase.com/docs/transactions.html
    [firebase runTransactionBlock:^FTransactionResult *(FMutableData *currentData) {
        [currentData setValue:values];

        return [FTransactionResult successWithValue:currentData];

    }          andCompletionBlock:^(NSError *error, BOOL committed, FDataSnapshot *snapshot) {
        if (block) block(snapshot.value, error);

    }             withLocalEvents:NO];
}

- (NestSDKObserverHandle)observeValuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {
    if (!block) return 0;

    Firebase *firebase = [self _firebaseWithURL:url];
    FirebaseHandle handle = [firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        block(snapshot.value, nil);

    }                                  withCancelBlock:^(NSError *error) {
        block(nil, error);
    }];

    // Map handle and url, since to remove observer we will need same instance of firebase to call removeObserver
    self.handleToURLDictionary[@(handle)] = url;

    return handle;
}

- (void)removeObserverWithHandle:(NestSDKObserverHandle)handle {
    Firebase *firebase = [self _firebaseWithURL:self.handleToURLDictionary[@(handle)]];
    [firebase removeObserverWithHandle:handle];
}

- (void)removeAllObservers {
    for (NSNumber *handle in self.handleToURLDictionary.allKeys) {
        [self removeObserverWithHandle:handle.unsignedIntegerValue];
    }

    [self.handleToURLDictionary removeAllObjects];
}

@end