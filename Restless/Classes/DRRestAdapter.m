//
//  DRRestAdapter.m
//  Restless
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRRestAdapter.h"
#import "DRProtocolImpl.h"
#import <objc/runtime.h>
#import "DRMethodDescription.h"
#import "DRJsonConverterFactory.h"

NSString* const DRHTTPErrorDomain = @"com.digitalrickshaw.Restless.httpErrorDomain";

//MARK:- for logger support via notifications
NSString* const DRHTTPRequestNotification = @"com.digitalrickshaw.Restless.httpRequestNotification";
NSString* const DRHTTPResponseNotification = @"com.digitalrickshaw.Restless.httpResponseNotification";
NSString* const DRHTTPRequestKey = @"com.digitalrickshaw.Restless.http.request";
NSString* const DRHTTPErrorKey = @"com.digitalrickshaw.Restless.http.error";
NSString* const DRHTTPResponseKey = @"com.digitalrickshaw.Restless.http.response";
NSString* const DRHTTPResponseDataKey = @"com.digitalrickshaw.Restless.http.response.data";

@interface DRRestAdapter ()

@property(nonatomic,strong,readonly) NSURL* endPoint;
@property(nonatomic,strong,readonly) NSBundle* bundle;
@property(nonatomic,strong,readonly) NSURLSession* urlSession;
@property(nonatomic,strong,readonly) id<DRConverterFactory> converterFactory;
@property(nonatomic,readonly) BOOL notificationEnabled;

- (instancetype)initWithBuilder:(DRRestAdapterBuilder*)builder;

@end



@implementation DRRestAdapterBuilder

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		// defaults
		self.bundle = [NSBundle mainBundle];
		self.urlSession = [NSURLSession sharedSession];
		self.converterFactory = [[DRJsonConverterFactory alloc] init];
	}
	
	return self;
}

- (DRRestAdapter*)build
{
	return [[DRRestAdapter alloc] initWithBuilder:self];
}

@end



@implementation DRRestAdapter

+ (instancetype)restAdapterWithBlock:(void(^)(DRRestAdapterBuilder* builder))block
{
	NSParameterAssert(block);
	
	DRRestAdapterBuilder* builder = [[DRRestAdapterBuilder alloc] init];
	block(builder);
	return [builder build];
}

- (instancetype)initWithBuilder:(DRRestAdapterBuilder*)builder
{
	self = [super init];
	
	if (self) {
		_endPoint = builder.endPoint;
		_bundle = builder.bundle;
		_urlSession = builder.urlSession;
		_converterFactory = builder.converterFactory;
        _notificationEnabled = builder.notificationEnabled;
	}
	
	return self;
}

- (Class)classImplForProtocol:(Protocol*)protocol
{
	NSString* protocolName = NSStringFromProtocol(protocol);
	NSString* className = [protocolName stringByAppendingString:@"_DRInternalImpl"];
	Class cls = nil;
	
	// make sure we only create the class once
	@synchronized(self.class) {
		cls = NSClassFromString(className);
		
		if (cls == nil) {
			cls = objc_allocateClassPair([DRProtocolImpl class], [className UTF8String], 0);
			class_addProtocol(cls, protocol);
			objc_registerClassPair(cls);
		}
	}
	
	return cls;
}

- (NSDictionary*)methodDescriptionsForProtocol:(Protocol*)protocol {
	NSURL* url = [self.bundle URLForResource:NSStringFromProtocol(protocol) withExtension:@"drproto"];
	NSAssert(url != nil, @"couldn't find proto file");
	NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
	NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
	
	for (NSString* key in jsonDict) {
		result[key] = [[DRMethodDescription alloc] initWithDictionary:jsonDict[key]];
	}
	
	return result.copy;
}

- (id)create:(Protocol*)protocol
{
	Class cls = [self classImplForProtocol:protocol];
	DRProtocolImpl* obj = [[cls alloc] init];
	obj.protocol = protocol;
	obj.endPoint = self.endPoint;
	obj.urlSession = self.urlSession;
	obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
	obj.converterFactory = self.converterFactory;
    obj.notificationEnabled = self.notificationEnabled;
	return obj;
}

@end
