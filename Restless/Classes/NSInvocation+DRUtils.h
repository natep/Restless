//
//  NSInvocation+DRUtils.h
//  Restless
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRTypeEncoding;

@interface NSInvocation (DRUtils)

- (DRTypeEncoding*)typeEncodingForParameterAtIndex:(NSUInteger)index;

- (NSObject*)objectValueForParameterAtIndex:(NSUInteger)index;

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index;

@end
