//
//  DRMethodDescription.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/3/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRMethodDescription.h"
#import "NSInvocation+DRUtils.h"

@implementation DRMethodDescription

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self) {
		_parameterNames = dictionary[@"parameterNames"];
		_returnType = dictionary[@"returnType"];
		_annotations = dictionary[@"annotations"];
	}
	
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@: %p, returnType: %@, params:%@, annotations:%@>",
			NSStringFromClass([self class]),
			self, self.returnType,
			self.parameterNames,
			self.annotations];
}

- (NSString*)httpMethod
{
	if (self.annotations[@"GET"]) {
		return @"GET";
	}
	
	NSAssert(NO, @"Could not determine HTTP method");
	return nil;
}

- (NSString*)parameterizedPathForInvocation:(NSInvocation*)invocation
{
	NSString* path = self.annotations[self.httpMethod];
	NSMutableString* paramedPath = path.mutableCopy;
	NSError* error = nil;
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\{([a-zA-Z0-9_]+)\\}" options:0 error:&error];
	
	NSArray *matches = [regex matchesInString:path
									  options:0
										range:NSMakeRange(0, [path length])];
	
	for (NSInteger i = matches.count - 1; i >=0; i--) {
		NSTextCheckingResult* match = matches[i];
		NSRange nameRange = [match rangeAtIndex:1];
		NSString* paramName = [path substringWithRange:nameRange];
		NSUInteger paramIdx = [self.parameterNames indexOfObject:paramName];
		
		NSAssert(paramIdx != NSNotFound, @"Unknown substitution variable in path: %@", paramName);
		
		NSString* paramValue = [invocation stringValueForParameterAtIndex:paramIdx];
		[paramedPath replaceCharactersInRange:match.range withString:paramValue];
	}
	
	return paramedPath.copy;
}

@end
