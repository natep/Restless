//
//  WebServiceProtocolTests.m
//  WebServiceProtocolTests
//
//  Created by Nate Petersen on 9/1/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DRRestAdapter.h"
#import "GitHubService.h"

@interface WebServiceProtocolTests : XCTestCase

@end

@implementation WebServiceProtocolTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProtocolCreation {
	DRRestAdapter* ra = [[DRRestAdapter alloc] initWithEndPoint:[NSURL URLWithString:@"https://api.github.com"]
														 bundle:[NSBundle bundleForClass:[DRRestAdapter class]]];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	XCTAssertNotNil(service);
	XCTAssertTrue([service respondsToSelector:@selector(listRepos:callback:)]);
	XCTAssertTrue([service.class conformsToProtocol:@protocol(GitHubService)]);
	
	XCTestExpectation *callBackExpectation = [self expectationWithDescription:@"callback"];
	
	[service listRepos:@"natep" callback:^(NSArray *result, NSError *error) {
		XCTAssertNil(error);
		XCTAssertNotNil(result);
		NSLog(@"got callback with result: %@", result);
		
		[callBackExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
		if (error) {
			NSLog(@"%@", error);
		}
	}];
}

@end
