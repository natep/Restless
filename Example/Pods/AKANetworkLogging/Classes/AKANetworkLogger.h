//
//  AKANetworkLogger.h
//  AKANetworking
//
//  Created by Arlo Armstrong on 3/2/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, AKANetworkLoggerOptions) {
    AKANetworkLoggerOptionsOff      = 0,
    
    AKANetworkLoggerOptionsCURL     = 1 << 0,
    AKANetworkLoggerOptionsRequest  = 1 << 1,
    AKANetworkLoggerOptionsResponse = 1 << 2,
    
    AKANetworkLoggerOptionsVerbose      = 1 << 8,
    AKANetworkLoggerOptionsOnlyErrors   = 1 << 9,
    
    AKANetworkLoggerOptionsDebugLevel   = AKANetworkLoggerOptionsCURL | AKANetworkLoggerOptionsRequest | AKANetworkLoggerOptionsResponse | AKANetworkLoggerOptionsVerbose,
    AKANetworkLoggerOptionsInfoLevel    = AKANetworkLoggerOptionsResponse,
    AKANetworkLoggerOptionsWarnLevel    = AKANetworkLoggerOptionsCURL | AKANetworkLoggerOptionsRequest | AKANetworkLoggerOptionsResponse | AKANetworkLoggerOptionsVerbose | AKANetworkLoggerOptionsOnlyErrors,
    AKANetworkLoggerOptionsErrorLevel   = AKANetworkLoggerOptionsResponse | AKANetworkLoggerOptionsOnlyErrors
};

@class AKANetworkTask;

@interface AKANetworkLogger : NSObject <NSCopying>

+ (instancetype)sharedNetworkLogger;

@property (nonatomic) AKANetworkLoggerOptions logOptions; // default is AKANetworkLoggerOptionsInfo

- (instancetype)initWithLogOptions:(AKANetworkLoggerOptions)logOptions;

// call these methods to cause logs to be output based on the logOptions property
- (void)logRequest:(NSURLRequest *)request;
- (void)logResponse:(NSURLResponse *)response responseData:(NSData *)responseData error:(NSError *)error originalRequest:(NSURLRequest *)request;

// possible to be overridden by a subclass to alter the format of the output
+ (NSDateFormatter *)defaultDateFormatter;

- (NSString *)curlStringForRequest:(NSURLRequest *)request;
- (NSString *)stringForLoggingRequest:(NSURLRequest *)request verbose:(BOOL)verbose;
- (NSString *)stringForLoggingResponse:(NSURLResponse *)response responseData:(NSData *)responseData error:(NSError *)error originalRequest:(NSURLRequest *)request verbose:(BOOL)verbose;

- (void)outputLogString:(NSString *)string; // override to do whatever - DLog, network logging etc. Default uses NSLog.

@end
