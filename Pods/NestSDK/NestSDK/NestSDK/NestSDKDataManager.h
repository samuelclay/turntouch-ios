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
#import <NestSDK/NestSDKService.h>

@protocol NestSDKStructure;
@protocol NestSDKThermostat;
@protocol NestSDKMetadata;
@protocol NestSDKSmokeCOAlarm;
@protocol NestSDKCamera;


#pragma mark typedef

/**
 * Describes the result of structure data update.
 */
typedef void (^NestSDKStructureUpdateHandler)(id <NestSDKStructure> structure, NSError *error);

/**
 * Describes the result of structure data request or data update.
 */
typedef void (^NestSDKStructuresArrayUpdateHandler)(NSArray <NestSDKStructure> *structuresArray, NSError *error);

/**
 * Describes the result of metadata data request.
 */
typedef void (^NestSDKMetadataUpdateHandler)(id <NestSDKMetadata> metadata, NSError *error);

/**
 * Describes the result of thermostat data request or data update.
 */
typedef void (^NestSDKThermostatUpdateHandler)(id <NestSDKThermostat> thermostat, NSError *error);

/**
 * Describes the result of smoke+CO alarm data request or data update.
 */
typedef void (^NestSDKSmokeCOAlarmUpdateHandler)(id <NestSDKSmokeCOAlarm> smokeCOAlarm, NSError *error);

/**
 * Describes the result of camera data request or data update.
 */
typedef void (^NestSDKCameraUpdateHandler)(id <NestSDKCamera> camera, NSError *error);

/**
 * Reads, observes and sets structures, devices and meta data.
 *
 * In order to use `NestSDKDataManager` your Nest Product must be authorized, e.g. `[NestSDKAccessToken currentToken]` must be set.
 */
@interface NestSDKDataManager : NSObject
#pragma mark Methods

/**
 * Get metadata data. Your block will be triggered when data is delivered.
 *
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)metadataWithBlock:(NestSDKMetadataUpdateHandler)block;


/**
 * Get structures data. Your block will be triggered when data is delivered.
 *
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)structuresWithBlock:(NestSDKStructuresArrayUpdateHandler)block;

/**
 * Listen for structures data changes. Your block will be triggered for the initial data and again whenever the data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param block The block that should be called with initial data, updates or errors happen.
 * @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (NestSDKObserverHandle)observeStructuresWithBlock:(NestSDKStructuresArrayUpdateHandler)block;

/**
 * Set structure data. Your block will be triggered when data is set.
 *
 * @param structure The structure with values to be set.
 * @param block The block that should be called when data is set or error happen.
 */
- (void)setStructure:(id <NestSDKStructure>)structure block:(NestSDKStructureUpdateHandler)block;


/**
 * Get thermostat data. Your block will be triggered when data is delivered.
 *
 * @param thermostatId The thermostat id to get data for.
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)thermostatWithId:(NSString *)thermostatId block:(NestSDKThermostatUpdateHandler)block;

/**
 * Listen for thermostat data changes. Your block will be triggered for the initial data and again whenever the data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param thermostatId The thermostat id listen get data changes for.
 * @param block The block that should be called with initial data, updates or errors happen.
 * @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (NestSDKObserverHandle)observeThermostatWithId:(NSString *)thermostatId block:(NestSDKThermostatUpdateHandler)block;

/**
 * Set thermostat data. Your block will be triggered when data is set.
 *
 * @param thermostat The thermostat with values to be set.
 * @param block The block that should be called when data is set or error happen.
 */
- (void)setThermostat:(id <NestSDKThermostat>)thermostat block:(NestSDKThermostatUpdateHandler)block;


/**
 * Get smoke+CO alarm data. Your block will be triggered when data is delivered.
 *
 * @param smokeCOAlarmId The smoke+CO alarm id to get data for.
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)smokeCOAlarmWithId:(NSString *)smokeCOAlarmId block:(NestSDKSmokeCOAlarmUpdateHandler)block;

/**
 * Listen for smoke+CO alarm data changes. Your block will be triggered for the initial data and again whenever the data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param smokeCOAlarmId The smoke+CO alarm id to listen data changes for.
 * @param block The block that should be called with initial data, updates or errors happen.
 * @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (NestSDKObserverHandle)observeSmokeCOAlarmWithId:(NSString *)smokeCOAlarmId block:(NestSDKSmokeCOAlarmUpdateHandler)block;


/**
 * Get camera data. Your block will be triggered when data is delivered.
 *
 * @param cameraId The camera id to get data for.
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)cameraWithId:(NSString *)cameraId block:(NestSDKCameraUpdateHandler)block;

/**
 * Listen for camera data changes. Your block will be triggered for the initial data and again whenever the data changes.
 *
 * Use removeObserverWithHandle: to stop receiving updates.
 *
 * @param cameraId The camera id to listen data changes for.
 * @param block The block that should be called with initial data, updates or errors happen.
 * @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (NestSDKObserverHandle)observeCameraWithId:(NSString *)cameraId block:(NestSDKCameraUpdateHandler)block;

/**
 * Set camera data. Your block will be triggered when data is set.
 *
 * @param camera The camera with values to be set.
 * @param block The block that should be called when data is set or error happen.
 */
- (void)setCamera:(id <NestSDKCamera>)camera block:(NestSDKCameraUpdateHandler)block;


/**
 * Get product data. Your block will be triggered when data is delivered.
 *
 * @param productId The product id to get data for.
 * @param companyId The company of product id.
 * @param block The block that should be called when data is delivered or error happen.
 */
- (void)productWithId:(NSString *)productId companyId:(NSString *)companyId block:(NestSDKCameraUpdateHandler)block;

/**
* Listen for product data changes. Your block will be triggered for the initial data and again whenever the data changes.
*
* Use removeObserverWithHandle: to stop receiving updates.
*
* @param productId The product id to get data for.
* @param companyId The company of product id.
* @param block The block that should be called with initial data, updates or errors happen.
* @return A handle used to unregister this block later using removeObserverWithHandle:
*/
- (NestSDKObserverHandle)observeProductWithId:(NSString *)productId companyId:(NSString *)companyId block:(NestSDKCameraUpdateHandler)block;


/**
 * Detach a block previously attached to this `NestSDKDataManager` instance with `observeStructuresWithBlock:`,
 * `observeThermostatWithId:block:`, `observeSmokeCOAlarmWithId:block:`, `observeCameraWithId:block:`.
 *
 * @param handle The handle returned by the call to `observeStructuresWithBlock:`, `observeThermostatWithId:block:`,
 * `observeSmokeCOAlarmWithId:block:`, `observeCameraWithId:block:` which we are trying to remove.
 */
- (void)removeObserverWithHandle:(NestSDKObserverHandle)handle;

/**
 * Detach all blocks previously attached to this `NestSDKDataManager` instance with `observeStructuresWithBlock:`,
 * `observeThermostatWithId:block:`, `observeSmokeCOAlarmWithId:block:`, `observeCameraWithId:block:`.
 */
- (void)removeAllObservers;

@end