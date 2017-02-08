//
//  NSObject+AKAAFNetworkingLogger.m
//  AKANetworking
//
//  Created by Arlo Armstrong on 3/12/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

#import "NSObject+AKANetworkNotificationLogger.h"
#import <objc/runtime.h>

static char AKANetworkNotificationLoggerNetworkLoggerKey;

@implementation NSObject (AKANetworkNotificationLogger)

- (AKANetworkNotificationLogger *)aka_networkLogger {
    return objc_getAssociatedObject(self, &AKANetworkNotificationLoggerNetworkLoggerKey);
}

- (void)setAka_networkLogger:(AKANetworkNotificationLogger *)networkLogger {
    objc_setAssociatedObject(self, &AKANetworkNotificationLoggerNetworkLoggerKey, networkLogger, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
