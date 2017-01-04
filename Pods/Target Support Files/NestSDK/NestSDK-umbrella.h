#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NestSDK.h"
#import "NestSDKAccessToken.h"
#import "NestSDKAccessTokenCache.h"
#import "NestSDKApplicationDelegate.h"
#import "NestSDKAuthenticableService.h"
#import "NestSDKAuthorizationManager.h"
#import "NestSDKAuthorizationManagerAuthorizationResult.h"
#import "NestSDKAuthorizationViewController.h"
#import "NestSDKCamera.h"
#import "NestSDKCameraDataModel.h"
#import "NestSDKCameraLastEvent.h"
#import "NestSDKCameraLastEventDataModel.h"
#import "NestSDKConnectWithNestButton.h"
#import "NestSDKDataManager.h"
#import "NestSDKDataManagerHelper.h"
#import "NestSDKDataModel.h"
#import "NestSDKDataModelProtocol.h"
#import "NestSDKDevice.h"
#import "NestSDKDeviceDataModel.h"
#import "NestSDKError.h"
#import "NestSDKETA.h"
#import "NestSDKETADataModel.h"
#import "NestSDKFirebaseService.h"
#import "NestSDKLogger.h"
#import "NestSDKMacroses.h"
#import "NestSDKMetaData.h"
#import "NestSDKMetadataDataModel.h"
#import "NestSDKProduct.h"
#import "NestSDKProductDataModel.h"
#import "NestSDKProductIdentification.h"
#import "NestSDKProductIdentificationDataModel.h"
#import "NestSDKProductLocation.h"
#import "NestSDKProductLocationDataModel.h"
#import "NestSDKProductResource.h"
#import "NestSDKProductResourceDataModel.h"
#import "NestSDKProductResourceUse.h"
#import "NestSDKProductResourceUseDataModel.h"
#import "NestSDKProductSoftware.h"
#import "NestSDKProductSoftwareDataModel.h"
#import "NestSDKRESTService.h"
#import "NestSDKService.h"
#import "NestSDKSmokeCOAlarm.h"
#import "NestSDKSmokeCOAlarmDataModel.h"
#import "NestSDKStructure.h"
#import "NestSDKStructureDataModel.h"
#import "NestSDKThermostat.h"
#import "NestSDKThermostatDataModel.h"
#import "NestSDKUtils.h"
#import "NestSDKWheres.h"
#import "NestSDKWheresDataModel.h"
#import "UIColor+NestBlue.h"

FOUNDATION_EXPORT double NestSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char NestSDKVersionString[];

