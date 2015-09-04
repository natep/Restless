//
//  DRRestAdapter.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRRestAdapter.h"
#import "DRProtocolImpl.h"
#import <objc/runtime.h>
#import "DRMethodDescription.h"


@interface DRRestAdapter ()

@property(nonatomic,strong,readonly) NSURL* endPoint;
@property(nonatomic,strong,readonly) NSBundle* bundle;

@end


@implementation DRRestAdapter

- (instancetype)initWithEndPoint:(NSURL*)endPoint bundle:(NSBundle*)bundle
{
	self = [super init];
	
	if (self) {
		_endPoint = endPoint;
		_bundle = bundle;
	}
	
	return self;
}

- (instancetype)initWithEndPoint:(NSURL*)endPoint
{
	return [self initWithEndPoint:endPoint bundle:[NSBundle mainBundle]];
}

- (Class)classImplForProtocol:(Protocol*)protocol
{
	// TODO: locking
	NSString* protocolName = NSStringFromProtocol(protocol);
	NSString* className = [protocolName stringByAppendingString:@"DRInternalImpl"];
	Class cls = NSClassFromString(className);
	
	if (cls == nil) {
		cls = objc_allocateClassPair([DRProtocolImpl class], [className UTF8String], 0);
		class_addProtocol(cls, protocol);
		objc_registerClassPair(cls);
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
	obj.methodDescriptions = [self methodDescriptionsForProtocol:protocol];
	return obj;
}

@end