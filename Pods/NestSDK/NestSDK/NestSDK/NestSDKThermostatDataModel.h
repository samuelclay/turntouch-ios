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
#import <CoreGraphics/CGBase.h>
#import <JSONModel/JSONModel.h>
#import "NestSDKDeviceDataModel.h"
#import <NestSDK/NestSDKThermostat.h>

@protocol Optional;


/**
 * Thermostat device data model.
 */
@interface NestSDKThermostatDataModel : NestSDKDeviceDataModel <NestSDKThermostat>
#pragma mark Properties

/**
 * Specifies language and region (or country) preference.
 */
@property(nonatomic, copy) NSString <Optional> *locale;

/**
 * Timestamp of the last successful interaction with the Nest service.
 */
@property(nonatomic) NSDate <Optional> *lastConnection;

/**
 * System ability to cool (has AC).
 */
@property(nonatomic) BOOL canCool;

/**
 * System ability to heat.
 */
@property(nonatomic) BOOL canHeat;

/**
 * Emergency Heat status in systems with heat pumps for cooling.
 */
@property(nonatomic) BOOL isUsingEmergencyHeat;

/**
 * System ability to control the fan independently from heating or cooling.
 */
@property(nonatomic) BOOL hasFan;

/**
 * Indicates if the fan timer is engaged; used with fanTimerTimeout to turn on the fan for a (user-specified) preset duration.
 */
@property(nonatomic) BOOL fanTimerActive;

/**
 * Timestamp showing when the fan timer reaches 0 (stop time).
 */
@property(nonatomic) NSDate <Optional> *fanTimerTimeout;

/**
 * Displayed when the thermostat is set to an energy-saving temperature.
 */
@property(nonatomic) BOOL hasLeaf;

/**
 * Fahrenheit or Celsius; used with temperature display.
 */
@property(nonatomic) NestSDKThermostatTemperatureScale temperatureScale;

/**
 * Desired temperature, in full degrees Fahrenheit (1°F). Used when hvacMode = "heat" or "cool".
 */
@property(nonatomic) NSUInteger targetTemperatureF;

/**
 * Desired temperature, in half degrees Celsius (0.5°C). Used when hvacMode = "heat" or "cool".
 */
@property(nonatomic) CGFloat targetTemperatureC;

/**
 * Maximum target temperature, displayed in whole degrees Fahrenheit (1°F). Used when hvacMode = "heat-cool" (Heat • Cool mode).
 */
@property(nonatomic) NSUInteger targetTemperatureHighF;

/**
 * Maximum target temperature, displayed in half degrees Celsius (0.5°C). Used when hvac_mode = "heat-cool" (Heat • Cool mode).
 */
@property(nonatomic) CGFloat targetTemperatureHighC;

/**
 * Minimum target temperature, displayed in whole degrees Fahrenheit (1°F). Used when hvac_mode = "heat-cool" (Heat • Cool mode).
 */
@property(nonatomic) NSUInteger targetTemperatureLowF;

/**
 * Minimum target temperature, displayed in half degrees Celsius (0.5°C). Used when hvac_mode = "heat-cool" (Heat • Cool mode).
 */
@property(nonatomic) CGFloat targetTemperatureLowC;

/**
 * Maximum away temperature, displayed in whole degrees Fahrenheit (1°F).
 */
@property(nonatomic) NSUInteger awayTemperatureHighF;

/**
 * Maximum away temperature, displayed in half degrees Celsius (0.5°C).
 */
@property(nonatomic) CGFloat awayTemperatureHighC;

/**
 * Minimum away temperature, displayed in whole degrees Fahrenheit (1°F).
 */
@property(nonatomic) NSUInteger awayTemperatureLowF;

/**
 * Minimum away temperature, displayed in half degrees Celsius (0.5°C).
 */
@property(nonatomic) CGFloat awayTemperatureLowC;

/**
 * Indicates HVAC system heating/cooling modes. For systems with both heating and cooling capability,
 * set this value to "heat-cool" (Heat • Cool mode) to get the best experience.
 *
 * Learn more about Heat • Cool mode: http://support.nest.com/article/What-is-Heat-Cool-mode
 */
@property(nonatomic) NestSDKThermostatHVACMode hvacMode;

/**
 * Temperature, measured at the device, in half degrees Celsius (0.5°C).
 */
@property(nonatomic) CGFloat ambientTemperatureC;

/**
 * Temperature, measured at the device, in whole degrees Fahrenheit (1°F).
 */
@property(nonatomic) NSUInteger ambientTemperatureF;

/**
 * Humidity, in percent (%) format, measured at the device.
 */
@property(nonatomic) NSUInteger humidity;

/**
 * Indicates whether HVAC system is actively heating, cooling or is off. Use this value to indicate HVAC activity state.
 */
@property(nonatomic) NestSDKThermostatHVACState hvacState;

@end