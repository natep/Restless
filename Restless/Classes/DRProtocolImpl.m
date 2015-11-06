//
//  DRProtocolImpl.m
//  Restless
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

/*
 * This big ugly method really needs to be refactored.
 */
- (void)handleInvocation:(NSInvocation*)invocation
{
	[invocation retainArguments];
	
	// track which paramters have been used
	NSMutableSet* consumedParameters = [[NSMutableSet alloc] init];
	
	// get method description
	NSString* sig = NSStringFromSelector(invocation.selector);
	DRMethodDescription* desc = self.methodDescriptions[sig];
	NSLog(@"you called '%@', which has the description:\n%@", sig, desc);
	
	NSAssert(desc.resultType != nil, @"Callback not defined for %@", sig);
	
	// construct path
	id<DRConverter> converter = [self.converterFactory converter];
	DRParameterizeResult<NSString*>* pathParamResult = [desc parameterizedPathForInvocation:invocation
																			  withConverter:converter];
	
	NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:pathParamResult.result];
	[consumedParameters unionSet:pathParamResult.consumedParameters];
	
	NSLog(@"full path: %@", fullPath);
	
	// construct request
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fullPath];
	request.HTTPMethod = [desc httpMethod];
	
	// get body
	DRParameterizeResult* bodyParamResult = [desc bodyForInvocation:invocation withConverter:converter];
	id bodyObj = bodyParamResult.result;
	[consumedParameters unionSet:bodyParamResult.consumedParameters];
	
	// set headers
	DRParameterizeResult<NSDictionary*>* headerParamResult = [desc parameterizedHeadersForInvocation:invocation
																					   withConverter:converter];
	for (NSString* key in headerParamResult.result) {
		[request setValue:headerParamResult.result[key] forHTTPHeaderField:key];
	}
	
	[consumedParameters unionSet:headerParamResult.consumedParameters];
	
	// we'll set this here in case it's not an upload task
	if ([bodyObj isKindOfClass:[NSData class]]) {
		request.HTTPBody = bodyObj;
	} else if ([bodyObj isKindOfClass:[NSInputStream class]]) {
		request.HTTPBodyStream = bodyObj;
	}
	
	__unsafe_unretained DRCallback callbackArg;
	NSUInteger numArgs = [invocation.methodSignature numberOfArguments];
	[invocation getArgument:&callbackArg atIndex:(numArgs - 1)];
	
	// must copy to heap
	DRCallback callback = [callbackArg copy];
	
	Class taskClass = [desc taskClass];
	NSAssert(taskClass != nil, @"could not determine session task type");
	NSURLSessionTask* task = nil;
	
	// somewhat complicated construction of correct task and setting of body
	if (taskClass == [NSURLSessionDownloadTask class]) {
		// if they provided a URL for the body, assume it is a local file and make a stream
		if ([bodyObj isKindOfClass:[NSURL class]]) {
			request.HTTPBodyStream = [NSInputStream inputStreamWithURL:bodyObj];
		}
		
		task = [self.urlSession downloadTaskWithRequest:request completionHandler:callback];
	} else {
		void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) =
			^(NSData *data, NSURLResponse *response, NSError *error) {
				id result = nil;
				
				if (!error) {
					Class subtype = [desc resultSubtype];
					result = [converter convertData:data toObjectOfClass:subtype];
				}
				
				callback(result, response, error);
			};
		
		if (taskClass == [NSURLSessionDataTask class]) {
			// if they provided a URL for the body, assume it is a local file and make a stream
			if ([bodyObj isKindOfClass:[NSURL class]]) {
				request.HTTPBodyStream = [NSInputStream inputStreamWithURL:bodyObj];
			}
			
			task = [self.urlSession dataTaskWithRequest:request
									  completionHandler:completionHandler];
		} else {
			if ([bodyObj isKindOfClass:[NSData class]]) {
				task = [self.urlSession uploadTaskWithRequest:request
													 fromData:bodyObj
											completionHandler:completionHandler];
			} else if ([bodyObj isKindOfClass:[NSURL class]]) {
				task = [self.urlSession uploadTaskWithRequest:request
													 fromFile:bodyObj
											completionHandler:completionHandler];
			}
		}
	}
	
	[invocation setReturnValue:&task];
}

@end
