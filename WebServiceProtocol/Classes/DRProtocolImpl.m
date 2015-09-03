//
//  DRProtocolImpl.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 8/31/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRProtocolImpl.h"
#import <objc/runtime.h>

@implementation DRProtocolImpl

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	struct objc_method_description desc = protocol_getMethodDescription(self.protocol, anInvocation.selector, YES, YES);
	
	if (desc.name == NULL && desc.types == NULL) {
		[super forwardInvocation:anInvocation];
	} else {
		NSString* sig = NSStringFromSelector(anInvocation.selector);
		NSLog(@"you called '%@', which has the annotations:\n%@", sig, self.annotations[sig]);
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	struct objc_method_description desc = protocol_getMethodDescription(self.protocol, aSelector, YES, YES);
	
	if (desc.name == NULL && desc.types == NULL) {
		return [super respondsToSelector:aSelector];
	} else {
		return YES;
	}
}

@end
