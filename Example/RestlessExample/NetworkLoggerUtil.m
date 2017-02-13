//
//  NetworkLoggerUtil.m
//  RestlessExample
//
//  Created by Aldrin Lenny on 9/02/17.
//  Copyright © 2017 Digital Rickshaw LLC. All rights reserved.
//

#import "NetworkLoggerUtil.h"

#import "AKANetworkLogger.h"
#import "DRRestAdapter.h"

@implementation NetworkLoggerUtil

+ (instancetype)sharedInstance {
    static NetworkLoggerUtil *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [[self alloc] init];
    });
    return sharedInst;
}

- (void)startLogging {
    
    [AKANetworkLogger sharedNetworkLogger].logOptions = AKANetworkLoggerOptionsDebugLevel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiRequestLogger:) name:DRHTTPRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiResponseLogger:) name:DRHTTPResponseNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)apiRequestLogger:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    if (!userInfo) {
        return;
    }
    NSURLRequest *request = (NSURLRequest *)userInfo[DRHTTPRequestKey];
    if (request) {
        [[AKANetworkLogger sharedNetworkLogger] logRequest:request];
    }
}

- (void)apiResponseLogger:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    if (!userInfo) {
        return;
    }
    NSURLRequest *request = (NSURLRequest *)userInfo[DRHTTPRequestKey];
    NSError *error = (NSError *)userInfo[DRHTTPErrorKey];
    if (error) {
        [[AKANetworkLogger sharedNetworkLogger] logResponse:nil responseData:nil error:error originalRequest:request];
    } else {
        NSURLResponse *response = (NSURLResponse *)userInfo[DRHTTPResponseKey];
        NSData *data = (NSData *)userInfo[DRHTTPResponseDataKey];
        [[AKANetworkLogger sharedNetworkLogger] logResponse:response responseData:data error:nil originalRequest:request];
    }
}

@end
