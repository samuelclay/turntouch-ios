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

#import "NestSDKUtils.h"

static const int kCelsiusToFahrenheitTemperatureShift = 32;
static const float kCelsiusToFahrenheitTemperatureMultiplier = 1.8f;

@implementation NestSDKUtils
#pragma mark Private

+ (NSDateFormatter *)_iso8601DateFormatter {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

    return formatter;
}

+ (CGFloat)_roundToHalfDegree:(float)degree {
    NSUInteger floatPart = (NSUInteger) (floor(degree * 10)) % 10;

    return (CGFloat) floor(degree) + (floatPart < .5f ? 0 : .5f);
}

#pragma mark Public

+ (NSUInteger)celsiusToFahrenheit:(CGFloat)celsius {
    return (NSUInteger) (roundf(celsius * kCelsiusToFahrenheitTemperatureMultiplier) + kCelsiusToFahrenheitTemperatureShift);
}

+ (CGFloat)fahrenheitToCelsius:(NSUInteger)fahrenheit {
    return [self _roundToHalfDegree:(fahrenheit - kCelsiusToFahrenheitTemperatureShift) / kCelsiusToFahrenheitTemperatureMultiplier];
}

+ (UIImage *)imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius scale:(CGFloat)scale {
    CGFloat size = (CGFloat) (1.0 + 2 * cornerRadius);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, (CGFloat) (cornerRadius + 1.0), 0.0);
    CGPathAddArcToPoint(path, NULL, size, 0.0, size, cornerRadius, cornerRadius);
    CGPathAddLineToPoint(path, NULL, size, (CGFloat) (cornerRadius + 1.0));
    CGPathAddArcToPoint(path, NULL, size, size, (CGFloat) (cornerRadius + 1.0), size, cornerRadius);
    CGPathAddLineToPoint(path, NULL, cornerRadius, size);
    CGPathAddArcToPoint(path, NULL, 0.0, size, 0.0, (CGFloat) (cornerRadius + 1.0), cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0.0, cornerRadius);
    CGPathAddArcToPoint(path, NULL, 0.0, 0.0, cornerRadius, 0.0, cornerRadius);
    CGPathCloseSubpath(path);

    CGContextAddPath(context, path);
    CGPathRelease(path);

    CGContextFillPath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [image stretchableImageWithLeftCapWidth:(NSInteger) cornerRadius topCapHeight:(NSInteger) cornerRadius];
}

+ (UIViewController *)viewControllerForView:(UIView *)view {
    UIResponder *responder = view.nextResponder;

    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *) responder;
        }

        responder = responder.nextResponder;
    }

    return nil;
}

+ (NSDictionary *)queryParametersDictionaryFromQueryString:(NSString *)queryString {
    NSMutableDictionary *queryParametersDictionary = [[NSMutableDictionary alloc] init];

    for (NSString *parameter in [queryString componentsSeparatedByString:@"&"]) {
        NSArray *parameterArray = [parameter componentsSeparatedByString:@"="];
        if (parameterArray.count != 2) continue;

        NSString *value = [parameterArray lastObject];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByRemovingPercentEncoding];

        queryParametersDictionary[parameterArray.firstObject] = value;
    }

    return queryParametersDictionary;
}

+ (NSDate *)dateWithISO8601FormatDateString:(NSString *)dateString {
    return [[self _iso8601DateFormatter] dateFromString:dateString];
}

+ (NSString *)iso8601FormatDateStringWithDate:(NSDate *)date {
    return [[self _iso8601DateFormatter] stringFromDate:date];
}

+ (BOOL)object:(id)object isEqualToObject:(id)other {
    if (object == other) {
        return YES;
    }

    if (!object || !other) {
        return NO;
    }

    return [object isEqual:other];
}

@end