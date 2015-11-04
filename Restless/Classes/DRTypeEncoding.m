//
//  DRTypeEncoding.m
//  Restless
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRTypeEncoding.h"

@interface DRTypeEncoding ()

@property(nonatomic,strong,readonly) NSString* encoding;

@end

@implementation DRTypeEncoding

+ (NSArray*)integerEncodings
{
	static NSArray* encodings = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		encodings = @[ @"c",
					   @"i",
					   @"s",
					   @"l",
					   @"q",
					   @"C",
					   @"I",
					   @"S",
					   @"L",
					   @"Q" ];
	});
	
	return encodings;
}

+ (NSDictionary*)formatSpecifiers
{
	static NSDictionary* specifiers = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		specifiers = @{
					   @"c" : @"%c",
					   @"i" : @"%d",
					   @"s" : @"%hd",
					   @"l" : @"%ld",
					   @"q" : @"%lld",
					   @"C" : @"%c",
					   @"I" : @"%u",
					   @"S" : @"%hu",
					   @"L" : @"%lu",
					   @"Q" : @"%llu",
					   @"f" : @"%f",
					   @"d" : @"%f",
					   @"@" : @"%@",
					   };
	});
	
	return specifiers;
}

- (instancetype)initWithTypeEncoding:(const char*)encoding
{
	self = [super init];
	
	if (self) {
		_encoding = [[NSString alloc] initWithCString:encoding encoding:NSASCIIStringEncoding];
	}
	
	return self;
}

- (DRTypeEncodingClass)encodingClass
{
	if ([self.encoding isEqualToString:@"@"]) {
		return DRObjectTypeEncodingClass;
	} else if ([self.encoding isEqualToString:@"f"] || [self.encoding isEqualToString:@"d"]) {
		return DRFloatingNumberTypeEncodingClass;
	} else if ([[self.class integerEncodings] containsObject:self.encoding]) {
		return DRIntegerNumberTypeEncodingClass;
	} else {
		return DROtherTypeEncodingClass;
	}
}

- (NSString*)formatSpecifier
{
	return [self.class formatSpecifiers][self.encoding];
}

@end
