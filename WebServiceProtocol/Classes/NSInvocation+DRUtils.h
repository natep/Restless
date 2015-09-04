//
//  NSInvocation+DRUtils.h
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (DRUtils)

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index;

@end
