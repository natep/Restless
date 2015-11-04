//
//  GitHubRepo.m
//  Restless
//
//  Created by Nate Petersen on 9/21/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "GitHubRepo.h"

@implementation GitHubRepo


- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self) {
		_name = dictionary[@"name"];
		_repoId = dictionary[@"id"];
		_htmlURL = dictionary[@"html_url"];
	}
	
	return self;
}

- (NSDictionary*)toDictionary
{
	return @{
			 @"name" : self.name,
			 @"id" : self.repoId,
			 @"html_url" : self.htmlURL
			 };
}

@end
