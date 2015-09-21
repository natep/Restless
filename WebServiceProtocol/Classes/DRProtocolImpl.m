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

typedef void (^DRCallback)(id result, NSURLResponse *response, NSError* error);

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
	
	NSAssert(desc.resultType != nil, @"Callback not defined for %@", sig);
	
	NSString* paramedPath = [desc parameterizedPathForInvocation:invocation];
	NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:paramedPath];
	
	NSLog(@"full path: %@", fullPath);
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fullPath];
	request.HTTPMethod = [desc httpMethod];
	
	__unsafe_unretained DRCallback callback;
	NSUInteger numArgs = [invocation.methodSignature numberOfArguments];
	[invocation getArgument:&callback atIndex:(numArgs - 1)];
	
	Class taskClass = [desc taskClass];
	NSAssert(taskClass != nil, @"could not determine session task type");
	NSURLSessionTask* task = nil;
	
	if (taskClass == [NSURLSessionDownloadTask class]) {
		task = [self.urlSession downloadTaskWithRequest:request completionHandler:callback];
	} else {
		void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) =
			^(NSData *data, NSURLResponse *response, NSError *error) {
				id result = nil;
				
				if (!error) {
					result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
				}
				
				callback(result, response, error);
			};
		
		if (taskClass == [NSURLSessionDataTask class]) {
			task = [self.urlSession dataTaskWithRequest:request
									  completionHandler:completionHandler];
		} else {
			// TODO: set upload data
			task = [self.urlSession uploadTaskWithRequest:request
												 fromData:nil
										completionHandler:completionHandler];
		}
	}
	
	[invocation setReturnValue:&task];
}

@end
