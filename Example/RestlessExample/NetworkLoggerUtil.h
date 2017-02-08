//
//  NetworkLoggerUtil.h
//  RestlessExample
//
//  Created by Aldrin Lenny on 9/02/17.
//  Copyright © 2017 Digital Rickshaw LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkLoggerUtil : NSObject

+ (instancetype)sharedInstance;

- (void)startLogging;
- (void)stopLogging;


@end
