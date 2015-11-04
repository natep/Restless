//
//  DRJsonConverter.m
//  Restless
//
//  Created by Nate Petersen on 9/8/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRJsonConverter.h"
#import "DRDictionaryConvertable.h"

@implementation DRJsonConverter

- (id)convertData:(NSData *)data toObjectOfClass:(Class)cls
{
	id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	
	if (cls == nil) {
		return jsonObject;
	} else if (cls == [NSString class]) {
		// I guess if they want a string, just return that directly
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	} else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
		return [[cls alloc] initWithDictionary:jsonObject];
	} else {
		NSMutableArray* result = [[NSMutableArray alloc] init];
		
		for (id element in jsonObject) {
			id convertedValue = [[cls alloc] initWithDictionary:element];
			[result addObject:convertedValue];
		}
		
		return result.copy;
	}
}

- (NSData*)convertObjectToData:(id)object
{
	id result = [self convertObjectToJSONValue:object];
	
	return [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
}

- (id)convertObjectToJSONValue:(id)object
{
	if ([NSJSONSerialization isValidJSONObject:object]) {
		return object;
	} else if ([object isKindOfClass:[NSArray class]]) {
		NSMutableArray* result = [[NSMutableArray alloc] init];
		
		for (id element in object) {
			id convertedObject = [self convertObjectToJSONValue:element];
			[result addObject:convertedObject];
		}
		
		return result.copy;
		
	} else if ([object isKindOfClass:[NSDictionary class]]) {
		NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
		
		for (id key in object) {
			id convertedObject = [self convertObjectToJSONValue:[object objectForKey:key]];
			result[key] = convertedObject;
		}
		
		return result.copy;
	} else {
		return [object toDictionary];
	}
}

- (NSString*)convertObjectToString:(id)object
{
	return [[NSString alloc] initWithData:[self convertObjectToData:object] encoding:NSUTF8StringEncoding];
}

@end
