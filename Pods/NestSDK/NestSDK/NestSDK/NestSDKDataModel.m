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

#import <objc/runtime.h>
#import "NestSDKDataModel.h"

#pragma mark const
static NSString *const kReadOnlyAttributeString = @",R";


@implementation NestSDKDataModel
#pragma mark Private

- (NSArray *)writablePropertiesArrayFromConformedProtocols {
    NSMutableArray *propertyNames = [NSMutableArray array];

    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained *protocols = class_copyProtocolList([self class], &protocolCount);

    for (unsigned i = 0; i < protocolCount; i++) {
        [propertyNames addObjectsFromArray:[self writablePropertyNamesArrayWithProtocol:(protocols[i])]];
    }

    free(protocols);

    return propertyNames;
}

#pragma mark Override

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    // All primitives are optional
    return YES;
}

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

- (id)copyWithZone:(NSZone *)zone {
    id <NestSDKDataModelProtocol> copy = (id <NestSDKDataModelProtocol>) [[[self class] allocWithZone:zone] init];

    if (copy) {
        [self copyPropertiesToDataModelCopy:copy];
    }

    return copy;
}

#pragma mark Public

- (id)copy {
    return [self copyWithZone:nil];
}

- (void)copyPropertiesToDataModelCopy:(id <NestSDKDataModelProtocol>)copy {
}

- (NSArray *)writablePropertyNamesArrayWithProtocol:(Protocol *)aProtocol {
    unsigned int propertyCount = 0;
    objc_property_t *properties = protocol_copyPropertyList(aProtocol, &propertyCount);

    NSMutableArray *propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];

        const char *c_attributes = property_getAttributes(property);
        NSString *propertyAttributesString = [NSString stringWithUTF8String:c_attributes];

        // Search only for writable properties
        if ([propertyAttributesString rangeOfString:kReadOnlyAttributeString].location == NSNotFound) {
            const char *name = property_getName(property);
            [propertyNames addObject:[NSString stringWithUTF8String:name]];
        }
    }

    free(properties);

    return propertyNames;
}

- (NSDictionary *)toWritableDataModelDictionary {
    return [self toDictionaryWithKeys:[self writablePropertiesArrayFromConformedProtocols]];
}


@end