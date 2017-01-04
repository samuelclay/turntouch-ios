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
#import <NestSDK/NestSDKETA.h>
#import <NestSDK/NestSDKWheres.h>
#import "NestSDKStructure.h"
#import "NestSDKDataModel.h"
#import "NestSDKETADataModel.h"
#import "NestSDKWheresDataModel.h"

@class NestSDKETADataModel;
@protocol NestSDKWheresDataModel;


/**
 * Data model for Nest structure.
 *
 * Users can add a maximum of two structures, with multiple devices per structure.
 */
@interface NestSDKStructureDataModel : NestSDKDataModel <NestSDKStructure>
#pragma mark Properties

/**
 * ID number of the structure.
 */
@property(nonatomic, copy) NSString <Optional> *structureId;

/**
 * List of thermostats in the structure, by unique device identifier.
 * This is an array of NSString objects that includes all thermostats in the structure.
 */
@property(nonatomic, copy) NSArray <Optional> *thermostats;

/**
 * List of smoke+CO alarms in the structure, by unique device identifier.
 * This is an array of NSString objects that includes all smoke+CO alarms in the structure.
 */
@property(nonatomic, copy) NSArray <Optional> *smokeCoAlarms;

/**
 * List of cameras in the structure, by unique device identifier.
 * This is an array of NSString objects that includes all cameras in the structure.
 */
@property(nonatomic, copy) NSArray <Optional> *cameras;

/**
 * A dictionary containing $company and $product_type information.
 * Use this object with the Resource use API to read a list of your device ids.
 * https://developer.nest.com/documentation/cloud/resource-use-guide
 */
@property(nonatomic, copy) NSDictionary <Optional> *devices;

/**
 * Indicates the state of the structure.
 *
 * In order for a structure to be in the Auto-Away state, all devices must also be in Auto-Away state.
 * When any device leaves the Auto-Away state, then the structure also leaves the Auto-Away state.
 */
@property(nonatomic) NestSDKStructureAwayState away;

/**
 * User-defined name of the structure.
 */
@property(nonatomic, copy) NSString <Optional> *name;

/**
 * Country code, in ISO 3166 alpha-2 format.
 */
@property(nonatomic, copy) NSString <Optional> *countryCode;

/**
 * Postal or zip code, depending on the country.
 */
@property(nonatomic, copy) NSString <Optional> *postalCode;

/**
 * Start time of the Energy rush hour event.
 */
@property(nonatomic) NSDate <Optional> *peakPeriodStartTime;

/**
 * End time of the Energy rush hour event.
 */
@property(nonatomic) NSDate <Optional> *peakPeriodEndTime;

/**
 * Time zone at the structure, in IANA time zone format.
 */
@property(nonatomic, copy) NSString <Optional> *timeZone;

/**
 * ETA is an object that can be set on a structure.
 * It is used to let Nest know that a user is expected to return home at a specific time.
 *
 * Learn more about ETA https://developer.nest.com/documentation/cloud/eta-guide
 */
@property(nonatomic) NestSDKETADataModel <Optional> *eta;

/**
 * Rush Hour Rewards enrollment status.
 *
 * Learn more about Rush Hour Rewards http://support.nest.com/article/What-is-Rush-Hour-Rewards
 */
@property(nonatomic) BOOL rhrEnrollment;

/**
 * An object containing where identifiers (whereId and name) for devices in the structure.
 *
 * Learn more about wheres https://developer.nest.com/documentation/cloud/how-to-structures-object#wheres
 */
@property(nonatomic) NSDictionary <Optional, NestSDKWheresDataModel> *wheres;

@end