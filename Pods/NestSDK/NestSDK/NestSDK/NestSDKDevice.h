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
#import <NestSDK/NestSDKDataModelProtocol.h>

/**
 * Base protocol for Nest devices data models.
 */
@protocol NestSDKDevice <NestSDKDataModelProtocol>
#pragma mark Properties

/**
 * Device unique identifier.
 */
@property(nonatomic, copy, readonly) NSString *deviceId;

/**
 * Software version.
 */
@property(nonatomic, copy, readonly) NSString *softwareVersion;

/**
 * Structure unique identifier.
 */
@property(nonatomic, copy, readonly) NSString *structureId;

/**
 * Display name of the device. This data value is presented in labels in the Nest app (https://home.nest.com/).
 *
 * Learn more about where names for
 *      Nest Thermostats: https://nest.com/support/article/How-do-I-change-the-name-of-my-Nest-Learning-Thermostat
 *      Nest Protects: https://nest.com/support/article/Learn-more-about-Nest-Protect-locations-names-and-labels
 *      Nest Cams: https://nest.com/support/article/How-do-I-change-the-name-of-my-Nest-Cam
 */
@property(nonatomic, copy, readonly) NSString *name;

/**
 * Long display name of the device. This data value is selected by the user and presented in labels in the Nest app. Similar to name.
 *
 * Learn more about where names for
 *      Nest Thermostats: https://nest.com/support/article/How-do-I-change-the-name-of-my-Nest-Learning-Thermostat
 *      Nest Protects: https://nest.com/support/article/Learn-more-about-Nest-Protect-locations-names-and-labels
 *      Nest Cams: https://nest.com/support/article/How-do-I-change-the-name-of-my-Nest-Cam
 */
@property(nonatomic, copy, readonly) NSString *nameLong;

/**
 * Device connection status with the Nest Service.
 */
@property(nonatomic, readonly) BOOL isOnline;

/**
 * whereId is a unique, Nest-generated identifier that represents name, the display name of the device.
 */
@property(nonatomic, copy, readonly) NSString *whereId;


@end