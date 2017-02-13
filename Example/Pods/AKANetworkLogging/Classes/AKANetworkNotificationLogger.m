//
//  AKANetworkNotificationLogger.m
//  AKANetworking
//
//  Created by Arlo Armstrong on 4/25/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

#import "AKANetworkNotificationLogger.h"

#import "NSURLRequest+AKANetworkLogger.h"
#import "NSURLResponse+AKANetworkLogger.h"
#import "NSObject+AKANetworkNotificationLogger.h"

@interface AKANetworkNotificationLogger ()

@property (nonatomic, getter = isLogging) BOOL logging;

@end

@implementation AKANetworkNotificationLogger

#pragma mark - Lifecycle

- (void)dealloc {
    [self stopLogging];
}

#pragma mark - Enable/disable logging

- (void)startLogging {
    [self startLoggingObject:nil];
}

- (void)startLoggingObject:(id)object {
    // the sharedNetworkLogger should observe all objects, not a specific object. Conversely
    // an instance of NetworkLogger which is not the sharedNetworkLogger is required to observe a specific object
    if ((self != self.class.sharedNetworkLogger) == !object) {
        return;
    }
    
    [self stopLogging];
    self.logging = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkTaskDidStart:) name:self.nameForNetworkTaskStartNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkTaskDidFinish:) name:self.nameForNetworkTaskFinishNotification object:object];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.logging = NO;
}

#pragma mark - Notifications

- (void)networkTaskDidStart:(NSNotification *)notification {
    NSURLRequest *request = [self requestFromNetworkNotification:notification];
    
    if (!request || ![self shouldRespondToNotification:notification]) {
        return;
    }
    
    request.aka_startDate = NSDate.date;
    
    [self logRequest:request];
}

- (void)networkTaskDidFinish:(NSNotification *)notification {
    NSURLRequest *request = [self requestFromNetworkNotification:notification];
    NSURLResponse *response = [self responseFromNetworkNotification:notification];
    NSData *responseData = [self dataFromNetworkNotification:notification];
    NSError *error = [self errorFromNetworkNotification:notification];
    
    if ((!request && !response) || ![self shouldRespondToNotification:notification]) {
        return;
    }
    
    response.aka_completionDate = NSDate.date;
    
    [self logResponse:response responseData:responseData error:error originalRequest:request];
}

#pragma mark - Private

- (BOOL)shouldRespondToNotification:(NSNotification *)notification {
    return self == self.class.sharedNetworkLogger || ![self.class.sharedNetworkLogger isLogging];
}

#pragma mark - Override

- (NSString *)nameForNetworkTaskStartNotification {
    return @"NetworkTaskStartNotification";
}

- (NSString *)nameForNetworkTaskFinishNotification {
    return @"NetworkTaskFinishNotification";
}

- (NSURLRequest *)requestFromNetworkNotification:(NSNotification *)notification {
    if ([notification.object respondsToSelector:@selector(originalRequest)]) {
        return [notification.object originalRequest];
    }
    return nil;
}

- (NSURLResponse *)responseFromNetworkNotification:(NSNotification *)notification {
    if ([notification.object respondsToSelector:@selector(response)]) {
        return [notification.object response];
    }
    return nil;
}

- (NSData *)dataFromNetworkNotification:(NSNotification *)notification {
    return nil;
}

- (NSError *)errorFromNetworkNotification:(NSNotification *)notification {
    if ([notification.object respondsToSelector:@selector(error)]) {
        return [notification.object error];
    }
    return nil;
}

@end
