//
//  DRMethodDescription.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/3/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRMethodDescription.h"
#import "NSInvocation+DRUtils.h"
#import "DRTypeEncoding.h"
#import "DRConverterFactory.h"

@implementation DRMethodDescription

+ (NSArray*)httpMethodNames
{
	static NSArray* names = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		names = @[
					@"GET",
					@"POST",
					@"DELETE",
					@"PUT",
					@"HEAD",
					@"PATCH"
				  ];
	});
	
	return names;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self) {
		_parameterNames = dictionary[@"parameterNames"];
		_resultType = dictionary[@"resultType"];
		_annotations = dictionary[@"annotations"];
		_taskType = dictionary[@"taskType"];
	}
	
	return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@: %p, resultType: %@, taskType:%@, params:%@, annotations:%@>",
			NSStringFromClass([self class]),
			self, self.resultType, self.taskType,
			self.parameterNames,
			self.annotations];
}

- (NSString*)httpMethod
{
	for (NSString* method in [self.class httpMethodNames]) {
		if (self.annotations[method]) {
			return method;
		}
	}
	
	NSAssert(NO, @"Could not determine HTTP method");
	return nil;
}

- (Class)taskClass
{
	NSString* taskString = [self.taskType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSArray* split = [taskString componentsSeparatedByString:@"*"];
	NSString* taskClassName = [[split firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return NSClassFromString(taskClassName);
}

- (Class)resultSubtype
{
	NSError* error = nil;
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"<[\\s]*([a-zA-Z0-9_]+)[\\s]*\\**[\\s]*>" options:0 error:&error];
	
	NSTextCheckingResult* match = [regex firstMatchInString:self.resultType options:0 range:NSMakeRange(0, self.resultType.length)];
	
	if (match && match.range.location != NSNotFound) {
		NSRange subtypeRange = [match rangeAtIndex:1];
		NSString* subtypeName = [self.resultType substringWithRange:subtypeRange];
		return NSClassFromString(subtypeName);
	} else {
		return nil;
	}
}

- (NSString*)parameterizedPathForInvocation:(NSInvocation*)invocation withConverter:(id<DRConverter>)converter
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
		
		// TODO: this should probably be allowed, in case some URL randomly contains "{not_a_param}"
		NSAssert(paramIdx != NSNotFound, @"Unknown substitution variable in path: %@", paramName);
		
		NSString* paramValue = nil;
		DRTypeEncoding* encoding = [invocation typeEncodingForParameterAtIndex:paramIdx];
		
		if (encoding.encodingClass == DRObjectTypeEncodingClass) {
			id obj = [invocation objectValueForParameterAtIndex:paramIdx];
			
			if ([obj isKindOfClass:[NSString class]]) {
				paramValue = obj;
			} else if ([obj isKindOfClass:[NSNumber class]]) {
				paramValue = [obj stringValue];
			} else if ([converter respondsToSelector:@selector(convertObjectToString:)]) {
				paramValue = [converter convertObjectToString:obj];
			} else {
				NSAssert(NO, @"Could not convert parameter: %@", paramName);
			}
		} else {
			paramValue = [invocation stringValueForParameterAtIndex:paramIdx];
		}
		
		paramValue = [paramValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
		
		[paramedPath replaceCharactersInRange:match.range withString:paramValue];
	}
	
	return paramedPath.copy;
}

@end
