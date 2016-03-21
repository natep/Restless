//
//  GitHubRepo.m
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import "GitHubRepo.h"

@implementation GitHubRepo

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self) {
		_name = dictionary[@"name"];
		_repoDescription = dictionary[@"description"];
	}
	
	return self;
}

- (NSDictionary*)toDictionary
{
	NSAssert(NO, @"not implemented");
	
	return nil;
}

@end
