//
//  NSURLRequest+AKANetworkLogger.h
//  AKANetworking
//
//  Created by Arlo Armstrong on 10/16/13.
//  Copyright (c) 2013 Arlo Armstrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (AKANetworkLogger)

- (NSDate *)aka_startDate;
- (void)setAka_startDate:(NSDate *)date;

@end
