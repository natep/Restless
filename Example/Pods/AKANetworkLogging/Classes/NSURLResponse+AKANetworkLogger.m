//
//  NSURLResponse+AKANetworkLogger.m
//  AKANetworking
//
//  Created by Arlo Armstrong on 10/16/13.
//  Copyright (c) 2013 Arlo Armstrong. All rights reserved.
//

#import "NSURLResponse+AKANetworkLogger.h"
#import <objc/runtime.h>

static char AKANetworkingResponseCompletionDateKey;

@implementation NSURLResponse (AKANetworkLogger)

- (NSDate *)aka_completionDate {
    return objc_getAssociatedObject(self, &AKANetworkingResponseCompletionDateKey);
}

- (void)setAka_completionDate:(NSDate *)date {
    objc_setAssociatedObject(self, &AKANetworkingResponseCompletionDateKey, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
