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
#import "NestSDKDataModel.h"
#import "NestSDKMetadata.h"

@protocol Optional;

/**
 * Additional data provided by Nest.
 *
 * Learn more about metadata https://developer.nest.com/documentation/cloud/metadata
 */
@interface NestSDKMetadataDataModel : NestSDKDataModel <NestSDKMetadata>
#pragma mark Properties

/**
 * Part of user authorization, your product will use an access token to make API calls to the Nest service.
 * This access token serves as proof that a user has authorized your product to make calls on their behalf.
 */
@property(nonatomic, copy) NSString <Optional> *accessToken;

/**
 * Client version is the last user-authorized version of a product, and is associated with an access_token.
 * You'll get client_version in metadata calls.
 *
 * When you update the permissions in a product, the client version is incremented and the user is notified that an updated is available.
 * Your users must accept the product update before they can use your new product.
 *
 * Learn more about client version https://developer.nest.com/documentation/cloud/client-version
 */
@property(nonatomic) NSUInteger clientVersion;

@end