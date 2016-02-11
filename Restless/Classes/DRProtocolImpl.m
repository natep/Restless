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
#import "DRRestAdapter.h"

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

- (void)cleanupInvocation:(NSInvocation*)invocation callingError:(NSError*)error callback:(DRCallback)callback
{
	id nilReturn = nil;
	[invocation setReturnValue:&nilReturn];
	
	[self.urlSession.delegateQueue addOperationWithBlock:^{
		callback(nil, nil, error);
	}];
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
	
	// get the callback
	__unsafe_unretained DRCallback callbackArg;
	NSUInteger numArgs = [invocation.methodSignature numberOfArguments];
	[invocation getArgument:&callbackArg atIndex:(numArgs - 1)];
	
	// must copy to heap
	DRCallback callback = [callbackArg copy];
	
	// construct path
	NSError* error = nil;
	id<DRConverter> converter = [self.converterFactory converter];
	DRParameterizeResult<NSString*>* pathParamResult = [desc parameterizedPathForInvocation:invocation
																			  withConverter:converter
																					  error:&error];
	
	if (error) {
		[self cleanupInvocation:invocation callingError:error callback:callback];
		return;
	}
	
	NSURL* fullPath = [self.endPoint URLByAppendingPathComponent:pathParamResult.result];
	[consumedParameters unionSet:pathParamResult.consumedParameters];
	
	NSLog(@"full path: %@", fullPath);
	
	// construct request
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:fullPath];
	request.HTTPMethod = [desc httpMethod];
	
	// get body
	DRParameterizeResult* bodyParamResult = [desc bodyForInvocation:invocation withConverter:converter error:&error];
	
	if (error) {
		[self cleanupInvocation:invocation callingError:error callback:callback];
		return;
	}
	
	id bodyObj = bodyParamResult.result;
	[consumedParameters unionSet:bodyParamResult.consumedParameters];
	
	// we'll set this here in case it's not an upload task
	if ([bodyObj isKindOfClass:[NSData class]]) {
		request.HTTPBody = bodyObj;
	} else if ([bodyObj isKindOfClass:[NSInputStream class]]) {
		request.HTTPBodyStream = bodyObj;
	}
	
	// set headers
	DRParameterizeResult<NSDictionary*>* headerParamResult = [desc parameterizedHeadersForInvocation:invocation
																					   withConverter:converter
																							   error:&error];
	
	if (error) {
		[self cleanupInvocation:invocation callingError:error callback:callback];
		return;
	}
	
	for (NSString* key in headerParamResult.result) {
		[request setValue:headerParamResult.result[key] forHTTPHeaderField:key];
	}
	
	[consumedParameters unionSet:headerParamResult.consumedParameters];
	
	// finally, leftover parameters go in the query
	NSMutableSet* queryParams = [NSMutableSet setWithArray:desc.parameterNames];
	[queryParams minusSet:consumedParameters];
	
	if (queryParams.count > 0) {
		NSURLComponents* urlComps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
		NSMutableArray* queryItems = urlComps.queryItems.mutableCopy;
		
		if (queryItems == nil) {
			queryItems = [[NSMutableArray alloc] init];
		}
		
		for (NSString* paramName in queryParams) {
			NSUInteger paramIdx = [desc.parameterNames indexOfObject:paramName];
			NSString* value = [desc stringValueForParameterAtIndex:paramIdx
													withInvocation:invocation
														 converter:converter
															 error:&error];
			
			if (error) {
				[self cleanupInvocation:invocation callingError:error callback:callback];
				return;
			}
			
			[queryItems addObject:[[NSURLQueryItem alloc] initWithName:paramName value:value]];
		}
		
		urlComps.queryItems = queryItems;
		request.URL = urlComps.URL;
	}
	
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
					NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
					
					if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
						
						if ([converter respondsToSelector:@selector(convertErrorData:forResponse:)]) {
							error = [converter convertErrorData:data forResponse:httpResponse];
						}
						
						if (!error) {
							NSDictionary* userInfo = nil;
							
							if (data) {
								NSString* errorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
								
								if (errorMessage) {
									userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
								}
							}
							
							error = [NSError errorWithDomain:DRHTTPErrorDomain code:httpResponse.statusCode userInfo:userInfo];
						}
					}
				}
				
				if (!error) {
					Class type = [desc resultConversionClass];
					result = [converter convertData:data toObjectOfClass:type error:&error];
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
