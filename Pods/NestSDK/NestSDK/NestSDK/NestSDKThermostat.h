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
#import <NestSDK/NestSDKDevice.h>

#pragma mark const
FOUNDATION_EXPORT const NSUInteger NestSDKThermostatTemperatureCAllowableMin;
FOUNDATION_EXPORT const NSUInteger NestSDKThermostatTemperatureCAllowableMax;

FOUNDATION_EXPORT const NSUInteger NestSDKThermostatTemperatureFAllowableMin;
FOUNDATION_EXPORT const NSUInteger NestSDKThermostatTemperatureFAllowableMax;


#pragma mark typedef
typedef NS_ENUM(NSUInteger, NestSDKThermostatTemperatureScale) {
    NestSDKThermostatTemperatureScaleUndefined = 0,
    NestSDKThermostatTemperatureScaleC,
    NestSDKThermostatTemperatureScaleF
};

typedef NS_ENUM(NSUInteger, NestSDKThermostatHVACMode) {
    NestSDKThermostatHVACModeUndefined = 0,
    NestSDKThermostatHVACModeHeat,
    NestSDKThermostatHVACModeCool,
    NestSDKThermostatHVACModeHeatCool,
    NestSDKThermostatHVACModeOff
};

typedef NS_ENUM(NSUInteger, NestSDKThermostatHVACState) {
    NestSDKThermostatHVACStateUndefined = 0,
    NestSDKThermostatHVACStateHeating,
    NestSDKThermostatHVACStateCooling,
    NestSDKThermostatHVACStateOff
};

/**
 * Protocol for Thermostat device data model
 */
@protocol NestSDKThermostat <NestSDKDevice>
#pragma mark Properties

/**
* Specifies language and region (or country) preference.
*/
@property(nonatomic, copy, readonly) NSString *locale;

/**
 * Timestamp of the last successful interaction with the Nest service.
 */
@property(nonatomic, readonly) NSDate *lastConnection;

/**
 * System ability to cool (has AC).
 */
@property(nonatomic, readonly) BOOL canCool;

/**
 * System ability to heat.
 */
@property(nonatomic, readonly) BOOL canHeat;

/**
 * Emergency Heat status in systems with heat pumps for cooling.
 */
@property(nonatomic, readonly) BOOL isUsingEmergencyHeat;

/**
 * System ability to control the fan independently from heating or cooling.
 */
@property(nonatomic, readonly) BOOL hasFan;

/**
 * Indicates if the fan timer is engaged; used with fanTimerTimeout to turn on the fan for a (user-specified) preset duration.
 */
@property(nonatomic) BOOL fanTimerActive;

/**
 * Timestamp showing when the fan timer reaches 0 (stop time).
 */
@property(nonatomic, readonly) NSDate *fanTimerTimeout;

/**
 * Displayed when the thermostat is set to an energy-saving temperature.
 */
@property(nonatomic, readonly) BOOL hasLeaf;

/**
 * Fahrenheit or Celsius; used with temperature display.
 */
@property(nonatomic, readonly) NestSDKThermostatTemperatureScale temperatureScale;

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
@property(nonatomic, readonly) NSUInteger awayTemperatureHighF;

/**
 * Maximum away temperature, displayed in half degrees Celsius (0.5°C).
 */
@property(nonatomic, readonly) CGFloat awayTemperatureHighC;

/**
 * Minimum away temperature, displayed in whole degrees Fahrenheit (1°F).
 */
@property(nonatomic, readonly) NSUInteger awayTemperatureLowF;

/**
 * Minimum away temperature, displayed in half degrees Celsius (0.5°C).
 */
@property(nonatomic, readonly) CGFloat awayTemperatureLowC;

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
@property(nonatomic, readonly) CGFloat ambientTemperatureC;

/**
 * Temperature, measured at the device, in whole degrees Fahrenheit (1°F).
 */
@property(nonatomic, readonly) NSUInteger ambientTemperatureF;

/**
 * Humidity, in percent (%) format, measured at the device.
 */
@property(nonatomic, readonly) NSUInteger humidity;

/**
 * Indicates whether HVAC system is actively heating, cooling or is off. Use this value to indicate HVAC activity state.
 */
@property(nonatomic, readonly) NestSDKThermostatHVACState hvacState;


@end