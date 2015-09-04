//
//  NSInvocation+DRUtils.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "NSInvocation+DRUtils.h"
#import "DRTypeEncoding.h"

@implementation NSInvocation (DRUtils)

- (NSString*)stringValueForParameterAtIndex:(NSUInteger)index
{
	// must increment past the first 2 implicit parameters
	index += 2;
	
	const char* type = [self.methodSignature getArgumentTypeAtIndex:index];
	DRTypeEncoding* encoding = [[DRTypeEncoding alloc] initWithTypeEncoding:type];
	
	switch (encoding.encodingClass) {
		case DRObjectTypeEncodingClass: {
			NSObject* obj = nil;
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
			NSAssert(NO, @"Unrecognized parameter type: %s", type);
			return nil;
		}
	}
}

@end
