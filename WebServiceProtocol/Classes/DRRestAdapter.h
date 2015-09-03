//
//  DRRestAdapter.h
//  WebServiceProtocol
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRRestAdapter : NSObject

- (instancetype)initWithEndPoint:(NSURL*)endPoint;

- (instancetype)initWithEndPoint:(NSURL*)endPoint bundle:(NSBundle*)bundle;

- (id)create:(Protocol*)protocol;

@end
