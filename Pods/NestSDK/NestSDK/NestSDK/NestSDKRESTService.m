#import "NestSDKRESTService.h"
#import "NestSDKStructureDataModel.h"
#import "NestSDKThermostatDataModel.h"
#import "NestSDKAccessToken.h"
#import "NestSDKSmokeCOAlarmDataModel.h"

#pragma mark macros

#pragma mark const

static NSString *const kMethodGet = @"GET";

static NSString *const kAPIEndpointBaseURL = @"https://developer-api.nest.com";

static NSString *const kAPIEndpointStructuresURLPath = @"/structures";
static NSString *const kAPIEndpointDevicesURLPath = @"/devices";
static NSString *const kAPIEndpointThermostatsURLPath = @"/thermostats";
static NSString *const kAPIEndpointSmokeCOAlarmsURLPath = @"/smoke_co_alarms";

#pragma mark enum

#pragma mark typedef


@implementation NestSDKRESTService {
#pragma mark Instance variables
    NSURLSession *_urlSession;
}

#pragma mark Initializer

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        urlSessionConfiguration.allowsCellularAccess = YES;
        urlSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        urlSessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        urlSessionConfiguration.timeoutIntervalForRequest = 8.0;
        urlSessionConfiguration.timeoutIntervalForResource = 8.0;
        urlSessionConfiguration.HTTPMaximumConnectionsPerHost = 5;

        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:nil];
    }

    return self;
}

#pragma mark Private

- (BOOL)p_isAuthorized {
    return [NestSDKAccessToken currentAccessToken] != nil;
}

- (NSURLRequest *)p_authorizedRequestWithURLString:(NSString *)requestString
                                           headers:(NSDictionary *)headersDictionary
                                              body:(NSData *)bodyData
                                     andHTTPMethod:(NSString *)httpMethod {

    // Add auth param, since auth header don't work
    requestString = [NSString stringWithFormat:@"%@?auth=%@", requestString, [NestSDKAccessToken currentAccessToken].tokenString];

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:requestString]];
    [urlRequest setHTTPMethod:httpMethod];
    [urlRequest setHTTPBody:bodyData];

    // Add headersDictionary
    for (NSString *key in headersDictionary.allKeys) {
        [urlRequest setValue:headersDictionary[key] forHTTPHeaderField:key];
    }

    // Add authorization header
    NSString *bearerString = [NSString stringWithFormat:@"Bearer %@", [NestSDKAccessToken currentAccessToken].tokenString];
    [urlRequest setValue:bearerString forHTTPHeaderField:@"Authorization"];

    return [urlRequest copy];
}

- (NSError *)p_unauthorizedError {
    return [NSError errorWithDomain:@"" code:0 userInfo:nil];
}

- (NSError *)p_missingArgumentsError {
    return [NSError errorWithDomain:@"" code:0 userInfo:nil];
}

- (NSError *)p_parseDataErrorWithError:(NSError *)error {
    return [NSError errorWithDomain:@"" code:0 userInfo:nil];
}

#pragma mark Notification selectors

#pragma mark Override

#pragma mark Public

- (void)getStructuresWithHandler:(NestSDKRESTServiceGetStructuresRequestHandler)handler {
    if (!handler) return;

    if (![self p_isAuthorized]) {
        handler(nil, [self p_unauthorizedError]);

        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@", kAPIEndpointBaseURL, kAPIEndpointStructuresURLPath];
    NSURLRequest *request = [self p_authorizedRequestWithURLString:urlString headers:nil body:nil andHTTPMethod:kMethodGet];

    [[_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            handler(nil, error);
            return;
        }

        NSDictionary *structuresDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            handler(nil, [self p_parseDataErrorWithError:error]);

            return;
        }

        NSMutableArray *structuresArray = [NestSDKStructureDataModel arrayOfModelsFromDictionaries:structuresDictionary.allValues error:&error];
        if (error) {
            handler(nil, [self p_parseDataErrorWithError:error]);

            return;
        }

        handler((NSArray <NestSDKStructure> *) structuresArray, nil);

    }] resume];
}

- (void)getThermostatWithId:(NSString *)thermostatId handler:(NestSDKRESTServiceGetThermostatRequestHandler)handler {
    if (!handler) return;

    if (![self p_isAuthorized]) {
        handler(nil, [self p_unauthorizedError]);

        return;
    }

    if (!thermostatId.length) {
        handler(nil, [self p_missingArgumentsError]);

        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/%@", kAPIEndpointBaseURL, kAPIEndpointDevicesURLPath,
                                                     kAPIEndpointThermostatsURLPath, thermostatId];

    NSURLRequest *request = [self p_authorizedRequestWithURLString:urlString headers:nil body:nil andHTTPMethod:kMethodGet];

    NSURLSessionDataTask *task = [_urlSession dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        handler(nil, error);

                                                        return;
                                                    }

                                                    NestSDKThermostatDataModel *thermostat = [[NestSDKThermostatDataModel alloc] initWithData:data error:&error];
                                                    if (error) {
                                                        handler(nil, error);

                                                        return;
                                                    }

                                                    handler(thermostat, nil);
                                                }];

    [task resume];
}

- (void)getSmokeCOAlarmWithId:(NSString *)smokeCOAlarmId handler:(NestSDKRESTServiceGetSmokeCOAlarmRequestHandler)handler {
    if (!handler) return;

    if (![self p_isAuthorized]) {
        handler(nil, [self p_unauthorizedError]);
        return;
    }

    if (!smokeCOAlarmId.length) {
        handler(nil, [self p_missingArgumentsError]);
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/%@", kAPIEndpointBaseURL, kAPIEndpointDevicesURLPath,
                                                     kAPIEndpointSmokeCOAlarmsURLPath, smokeCOAlarmId];

    NSURLRequest *request = [self p_authorizedRequestWithURLString:urlString headers:nil body:nil andHTTPMethod:kMethodGet];

    NSURLSessionDataTask *task = [_urlSession dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        handler(nil, error);

                                                        return;
                                                    }

//                                                    error = [self p_errorFromResponse:response];
//                                                    if (error) {
//                                                        handler(nil, error);
//
//                                                        return;
//                                                    }

                                                    NestSDKSmokeCOAlarmDataModel *smokeCOAlarm = [[NestSDKSmokeCOAlarmDataModel alloc] initWithData:data error:&error];
                                                    if (error) {
                                                        handler(nil, error);

                                                        return;
                                                    }

                                                    handler(smokeCOAlarm, nil);
                                                }];
    [task resume];
}

- (void)authenticateWithAccessToken:(NestSDKAccessToken *)accessToken completionBlock:(NestSDKAuthenticableServiceCompletionBlock)completionBlock {

}

- (void)unauthenticate {

}

- (void)valuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {

}

- (void)setValues:(NSDictionary *)values forURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {

}

- (NestSDKObserverHandle)observeValuesForURL:(NSString *)url withBlock:(NestSDKServiceUpdateBlock)block {
    return 0;
}

- (void)removeObserverWithHandle:(NestSDKObserverHandle)handle {

}

- (void)removeAllObservers {

}


#pragma mark IBAction

#pragma mark Protocol @protocol-name

#pragma mark Delegate @delegate-name

@end