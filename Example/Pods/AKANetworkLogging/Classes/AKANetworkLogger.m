//
//  AKANetworkLogger.m
//  AKANetworking
//
//  Created by Arlo Armstrong on 3/2/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

#import "AKANetworkLogger.h"
#import "NSURLRequest+AKANetworkLogger.h"
#import "NSURLResponse+AKANetworkLogger.h"

@implementation AKANetworkLogger

+ (instancetype)sharedNetworkLogger {
    static id AKANetworkLoggerSharedNetworkLogger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AKANetworkLoggerSharedNetworkLogger = [[self alloc] init];
    });
    
    return AKANetworkLoggerSharedNetworkLogger;
}

#pragma mark - Lifecycle

- (instancetype)init {
    return [self initWithLogOptions:AKANetworkLoggerOptionsInfoLevel];
}

- (instancetype)initWithLogOptions:(AKANetworkLoggerOptions)logOptions {
    self = [super init];
    if (!self) {
        return nil;
    }
    _logOptions = logOptions;
    return self;
}

#pragma mark - Determine what to output based on logOptions

- (void)logRequest:(NSURLRequest *)request {
    [self logRequest:request ignoreErrorFlag:NO];
}

- (void)logRequest:(NSURLRequest *)request ignoreErrorFlag:(BOOL)ignoreErrorFlag {
    if ((self.logOptions & AKANetworkLoggerOptionsOnlyErrors) > 0 && !ignoreErrorFlag) {
        return;
    }
    if ((self.logOptions & AKANetworkLoggerOptionsCURL) > 0) {
        [self outputLogString:[self curlStringForRequest:request]];
    }
    if ((self.logOptions & AKANetworkLoggerOptionsRequest) > 0) {
        [self outputLogString:[self stringForLoggingRequest:request verbose:(self.logOptions & AKANetworkLoggerOptionsVerbose) > 0]];
    }
}

- (void)logResponse:(NSURLResponse *)response responseData:(NSData *)responseData error:(NSError *)error originalRequest:(NSURLRequest *)request {
    if ((self.logOptions & AKANetworkLoggerOptionsOnlyErrors) > 0) {
        BOOL errorStatusCode = NO;
        if ([response respondsToSelector:@selector(statusCode)]) {
            NSInteger statusCode = [(id)response statusCode];
            errorStatusCode = statusCode < 200 || statusCode >= 300;
        }
        if (error || errorStatusCode) {
            [self logRequest:request ignoreErrorFlag:YES];
        } else {
            return;
        }
    }
    if ((self.logOptions & AKANetworkLoggerOptionsResponse) > 0) {
        [self outputLogString:[self stringForLoggingResponse:response responseData:responseData error:error originalRequest:request verbose:(self.logOptions & AKANetworkLoggerOptionsVerbose) > 0]];
    }
}

#pragma mark - Prime candidates for overriding

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *AKANetworkLoggerDefaultDateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AKANetworkLoggerDefaultDateFormatter = [[NSDateFormatter alloc] init];
        AKANetworkLoggerDefaultDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    
    return AKANetworkLoggerDefaultDateFormatter;
}

- (NSString *)curlStringForRequest:(NSURLRequest *)request {
    if (!request) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"curl --verbose --request %@", request.HTTPMethod];
    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [result appendFormat:@" --header '%@: %@'", key, value];
    }];
    if (request.HTTPBody && ![@[@"GET", @"HEAD", @"DELETE"] containsObject:request.HTTPMethod.uppercaseString]) {
        NSString *bodyDataAsString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (bodyDataAsString) {
            [result appendFormat:@" --data '%@'", bodyDataAsString];
        } else {
            [result appendFormat:@" --data-binary '%@'", @"<Binary Data>"];
        }
    }
    [result appendFormat:@" '%@'", request.URL.absoluteString];
    return result;
}

- (NSString *)stringForLoggingRequest:(NSURLRequest *)request verbose:(BOOL)verbose {
    NSMutableString *result = [[NSMutableString alloc] init];
    if ((self.logOptions & AKANetworkLoggerOptionsResponse) > 0) {
        [result appendString:@"Request: "];
    }
    [result appendFormat:@"%@ %@", request.HTTPMethod, request.URL.absoluteString];
    if (verbose) {
        [result appendFormat:@"\n%@\nHeaders:\n%@", [self.class.defaultDateFormatter stringFromDate:request.aka_startDate], request.allHTTPHeaderFields];
        if ([request.HTTPBody length] > 0) {
            [result appendFormat:@"\nBody:\n%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] ?: @"<Binary Data>"];
        } else if (request.HTTPBodyStream) {
            [result appendFormat:@"\nBody:\n<Stream Data>"];
        }
    }
    return result;
}

- (NSString *)stringForLoggingResponse:(NSURLResponse *)response responseData:(NSData *)responseData error:(NSError *)error originalRequest:(NSURLRequest *)request verbose:(BOOL)verbose {
    NSMutableString *result = [[NSMutableString alloc] init];
    if ((self.logOptions & AKANetworkLoggerOptionsRequest) > 0) {
        [result appendString:@"Response: "];
    }
    [result appendFormat:@"%@ %@", request.HTTPMethod, request.URL.absoluteString];
    if ([response respondsToSelector:@selector(statusCode)]) {
        [result appendFormat:@"\nStatus %ld", (long)[(id)response statusCode]];
    }
    if (verbose) {
        [result appendFormat:@" %.2fs", [response.aka_completionDate timeIntervalSinceDate:request.aka_startDate]];
    }
    if (error) {
        [result appendFormat:@"\nError:%@", error];
    }
    if (verbose) {
        if ([response respondsToSelector:@selector(allHeaderFields)]) {
            [result appendFormat:@"\nHeaders:\n%@", [(id)response allHeaderFields]];
        }
        if ([responseData length] > 0) {
            [result appendFormat:@"\nBody:\n%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ?: @"<Binary Data>"];
        }
    }
    return result;
}

- (void)outputLogString:(NSString *)string {
    NSLog(@"%@", string);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    AKANetworkLogger *result = [self.class allocWithZone:zone];
    result.logOptions = self.logOptions;
    return result;
}

@end
