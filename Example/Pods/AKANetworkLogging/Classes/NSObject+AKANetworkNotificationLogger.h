//
//  NSObject+AKAAFNetworkingLogger.h
//  AKANetworking
//
//  Created by Arlo Armstrong on 3/12/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKANetworkNotificationLogger;

// similar to NSObject+AKANetworking
// this is a category on NSObject because NSURLSessionTask does not work. I assume this has to do with class clusters - __NSCFLocalSessionTask is the class I most often see but that is private.
@interface NSObject (AKANetworkNotificationLogger)

- (AKANetworkNotificationLogger *)aka_networkLogger;
- (void)setAka_networkLogger:(AKANetworkNotificationLogger *)networkLogger;

@end
