//
//  NSURLResponse+AKANetworkLogger.h
//  AKANetworking
//
//  Created by Arlo Armstrong on 10/16/13.
//  Copyright (c) 2013 Arlo Armstrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (AKANetworkLogger)

- (NSDate *)aka_completionDate;
- (void)setAka_completionDate:(NSDate *)date;

@end
