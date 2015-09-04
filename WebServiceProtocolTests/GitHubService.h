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

@protocol GitHubService <DRWebService>

@GET("/users/{user}/repos")
@Headers("Cache-Control: max-age=640000")
- (void)listRepos:(NSString*)user callback:DR_CALLBACK(NSArray*)callback;

@Headers("Cache-Control: max-age=640000")
- (NSArray*)listWikis:(NSString*)user fromDate:(NSDate*)date;

@Headers("Cache-Control: max-age=640000")
- (NSArray*)listEndpoints;

@end

#endif
