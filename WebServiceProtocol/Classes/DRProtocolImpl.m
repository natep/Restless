//
//  DRProtocolImpl.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 8/31/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRProtocolImpl.h"
#import <objc/runtime.h>
#import "DRMethodDescription.h"
#import "DRConverterFactory.h"

typedef void (^DRCallback)(id result, NSError* error);

@implementation DRProtocolImpl

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	struct objc_method_description desc = protocol_getMethodDescription(self.protocol, anInvocation.selector, YES, YES);
	
	if (desc.name == NULL && desc.types == NULL) {
		[super forwardInvocation:anInvocation];
	} else {
		[self handleInvocation:anInvocation];
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

- (void)handleInvocation:(NSInvocation*)invocation
{
	[invocation retainArguments];
	
	NSString* sig = NSStringFromSelector(invocation.selector);
	DRMethodDescription* desc = self.methodDescriptions[sig];
	NSLog(@"you called '%@', which has the description:\n%@", sig, desc);
	
	NSAssert(desc.returnType != nil, @"Callback not defined for %@", sig);
	
	NSString* paramedPath = [desc parameterizedPathForInvocation:invocation];
	NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:paramedPath];
	
	NSLog(@"full path: %@", fullPath);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fullPath];
	request.HTTPMethod = [desc httpMethod];
	
	/*
	 * Make sure we don't get dealloc'd before we are done. This can happen
	 * with fire-and-forget instances.
	 */
	__block DRProtocolImpl* strongSelf = self;
	
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request
											completionHandler:
		^(NSData *data, NSURLResponse *response, NSError *error) {
			id result = nil;
			
			if (!error) {
				result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			}
			
			__unsafe_unretained DRCallback callback;
			NSUInteger numArgs = [invocation.methodSignature numberOfArguments];
			[invocation getArgument:&callback atIndex:(numArgs - 1)];
			callback(result, error);
			
			strongSelf = nil;
		}];

	[task resume];
}

@end
