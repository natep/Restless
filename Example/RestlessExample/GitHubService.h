//
//  GitHubService.h
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#ifndef GitHubService_h
#define GitHubService_h

#import <Restless.h>

@class GitHubRepo;
@class GitHubIssue;

@protocol GitHubService <DRWebService>

@GET("/users/{user}/repos")
- (NSURLSessionDataTask*)listRepos:(NSString*)user
						  callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;

@GET("/repos/{user}/{repo}/issues")
- (NSURLSessionDataTask*)listIssuesForUser:(NSString*)user
									  repo:(NSString*)repo
								  callback:DR_CALLBACK(NSArray<GitHubIssue*>*)callback;

@end

#endif /* GitHubService_h */
