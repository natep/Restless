//
//  NSInvocation+DRUtils.m
//  Restless
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "NSInvocation+DRUtils.h"
#import "DRTypeEncoding.h"

@implementation NSInvocation (DRUtils)

- (DRTypeEncoding*)typeEncodingForParameterAtIndex:(NSUInteger)index
{
	// must increment past the first 2 implicit parameters
	index += 2;
	
	const char* type = [self.methodSignature getArgumentTypeAtIndex:index];
	return [[DRTypeEncoding alloc] initWithTypeEncoding:type];
}

- (NSObject*)objectValueForParameterAtIndex:(NSUInteger)index
{
	// must increment past the first 2 implicit parameters
	index += 2;
	
	NSObject* __unsafe_unretained obj = nil;
	[self getArgument:&obj atIndex:index];
	
	return obj;
}

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index
{
	DRTypeEncoding* encoding = [self typeEncodingForParameterAtIndex:index];
	
	// must increment past the first 2 implicit parameters
	index += 2;
	
	switch (encoding.encodingClass) {
		case DRObjectTypeEncodingClass: {
			NSObject* __unsafe_unretained obj = nil;
			[self getArgument:&obj atIndex:index];
			return [NSString stringWithFormat:@"%@", obj];
		}
			
		case DRIntegerNumberTypeEncodingClass: {
			long long value = 0;
			[self getArgument:&value atIndex:index];
			return [NSString stringWithFormat:[encoding formatSpecifier], value];
		}
			
		case DRFloatingNumberTypeEncodingClass: {
			double value = 0;
			[self getArgument:&value atIndex:index];
			return [NSString stringWithFormat:[encoding formatSpecifier], value];
		}
			
		case DROtherTypeEncodingClass: {
			NSAssert(NO, @"Unrecognized parameter type");
			return nil;
		}
	}
}

@end
