//
//  GitHubIssue.m
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import "GitHubIssue.h"

@implementation GitHubIssue

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self) {
		_title = dictionary[@"title"];
		_body = dictionary[@"body"];
	}
	
	return self;
}

- (NSDictionary*)toDictionary
{
	NSAssert(NO, @"not implemented");
	
	return nil;
}

@end
