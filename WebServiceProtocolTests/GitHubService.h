//
//  GitHubService.h
//  WebServiceProtocolTests
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
@Headers({"Accept" : "application/vnd.github.v3.full+json", "User-Agent" : "Retrofit-Sample-App"})
- (NSURLSessionDataTask*)listRepos:(NSString*)user callback:DR_CALLBACK(NSArray<GitHubRepo*>*)callback;

@GET("/users/{user}/wikis")
- (NSURLSessionDataTask*)listWikis:(NSString*)user fromDate:(NSDate*)date;

@GET("/endpoints")
- (NSURLSessionDataTask*)listEndpoints;

@end

#endif
