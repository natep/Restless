//
//  NSURLRequest+AKANetworkLogger.m
//  AKANetworking
//
//  Created by Arlo Armstrong on 10/16/13.
//  Copyright (c) 2013 Arlo Armstrong. All rights reserved.
//

#import "NSURLRequest+AKANetworkLogger.h"
#import <objc/runtime.h>

static char AKANetworkingRequestStartDateKey;

@implementation NSURLRequest (AKANetworkLogger)

- (NSDate *)aka_startDate {
    return objc_getAssociatedObject(self, &AKANetworkingRequestStartDateKey);
}

- (void)setAka_startDate:(NSDate *)date {
    objc_setAssociatedObject(self, &AKANetworkingRequestStartDateKey, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
