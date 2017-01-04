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
#import <JSONModel/JSONModel.h>
#import <NestSDK/NestSDKWheres.h>
#import "NestSDKDataModel.h"

@protocol Optional;

/**
 * NestSDKWheres protocol is used to specify type of data presented in NSDictionary/NSArray instances returned by result handlers.
 */
@protocol NestSDKWheresDataModel <NestSDKWheres>
@end


/**
 * NestSDKWheresDataModel is an object set on a structure, containing where identifiers (whereId and name).
 * Use NestSDKWheresDataModel to create custom where names, or access standard where names.
 *
 * Access to the wheres object requires Product data read/write permission.
 */
@interface NestSDKWheresDataModel : NestSDKDataModel <NestSDKWheres>
#pragma mark Properties

/**
 * A unique, Nest-generated identifier that represents name.
 * Use this value with the /$company/ object to send resource use.
 * whereId is read-only, and is created automatically in the call to create a custom where name.
 */
@property(nonatomic, copy) NSString <Optional> *whereId;

/**
 * The display name of the device
 *
 * Considerations
 *      name cannot be edited or deleted after creation
 *      name must be unique within the structure
 *      If a device is paired to a structure, the custom where name associated with the device is accessible from the /structures/ path
 *      To move a device with a custom where name to a different structure, unpair the device, then re-pair the device with the desired name
 */
@property(nonatomic, copy) NSString <Optional> *name;

@end