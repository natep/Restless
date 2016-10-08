//
//  GitHubService.h
//  RestlessTests
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright (c) 2015 Digital Rickshaw. All rights reserved.
//

#ifndef FitTest_GitHubService_h
#define FitTest_GitHubService_h

#import "DRWebService.h"
#import "GitHubRepo.h"

@protocol GitHubService <DRWebService>

@GET("/users/{user}/repos")
- (NSURLSessionDataTask*)listRepos:(NSString*)user
						  callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;

@GET("/users/{user}/repos?sort=desc")
- (NSURLSessionDataTask*)listReposDesc:(NSString*)user
						  callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;

@GET("/users/{user}/wikis")
- (NSURLSessionDataTask*)listWikis:(NSString*)user
						  fromDate:(NSDate*)date
						  callback:DR_CALLBACK(NSArray*)callback;

@POST("/updatePic")
@Body("data")
@Headers({"Accept" : "application/vnd.github.v3.full+json", "User-Agent" : "Sub: {agent}"})
- (NSURLSessionUploadTask*)updateProfilePic:(NSData*)data
									  agent:(NSString*)agent
								   callback:DR_CALLBACK(NSString*)callback;

@POST("/updatePic")
@Body("data")
@Headers({"Accept" : "application/vnd.github.v3.full+json", "User-Agent" : "Sub: {agent}"})
- (NSURLSessionUploadTask*)updateProfilePic:(NSData*)data
									  agent:(NSString*)agent
									 query1:(NSString*)query1
									 query2:(NSString*)query2
								   callback:DR_CALLBACK(NSString*)callback;

@POST("/example/formEncodingTest")
@FormUrlEncoded
- (NSURLSessionDataTask*)submitName:(NSString*)name
								age:(NSUInteger)age
							formula:(NSString*)formula
						   callback:DR_CALLBACK(NSArray*)callback;

@end

#endif
