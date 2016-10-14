//
//  RestlessTests.m
//  RestlessTests
//
//  Created by Nate Petersen on 9/1/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GitHubService.h"
#import <OHHTTPStubs.h>
#import <OHPathHelpers.h>
#import "GitHubRepo.h"
#import "Restless.h"

@interface RestlessTests : XCTestCase

@end

@implementation RestlessTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[OHHTTPStubs removeAllStubs];
	
    [super tearDown];
}

- (void)testProtocolCreation {
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	XCTAssertNotNil(service);
	XCTAssertTrue([service respondsToSelector:@selector(listRepos:callback:)]);
	XCTAssertTrue([service.class conformsToProtocol:@protocol(GitHubService)]);
}

- (void)testProtocolEndToEndSuccess {
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"api.github.com"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
		if ([request.URL.path isEqualToString:@"/users/natep/repos"]) {
			NSString* fixture = OHPathForFile(@"listReposResponse.json", self.class);
			return [OHHTTPStubsResponse responseWithFileAtPath:fixture
													statusCode:200
													   headers:@{@"Content-Type":@"application/json"}];
		} else {
			NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorBadURL userInfo:nil];
			return [OHHTTPStubsResponse responseWithError:error];
		}
		
	}];
	
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	XCTestExpectation *callBackExpectation = [self expectationWithDescription:@"callback"];
	
	NSURLSessionDataTask* task = [service listRepos:@"natep"
										   callback:^(NSArray<GitHubRepo*>* result,
													  NSURLResponse *response,
													  NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			XCTAssertNil(error);
			XCTAssertNotNil(result);
			XCTAssertTrue([result isKindOfClass:[NSArray class]]);
			XCTAssertEqual([result count], 4);
			XCTAssertTrue([[result firstObject] isKindOfClass:[GitHubRepo class]]);
			GitHubRepo* repo = [result firstObject];
			XCTAssertEqualObjects(repo.repoId, @(32614184));
			
			[callBackExpectation fulfill];
		});
	}];
	
	[task resume];
	
	[self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
		if (error) {
			NSLog(@"%@", error);
		}
	}];
}

- (void)testProtocolEndToEndFailure {
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"api.github.com"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
		return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
																		  code:kCFURLErrorBadServerResponse
																	  userInfo:nil]];
	}];
	
	
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	XCTestExpectation *callBackExpectation = [self expectationWithDescription:@"callback"];
	
	NSURLSessionDataTask* task = [service listRepos:@"natep" callback:^(NSArray *result, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			XCTAssertNotNil(error);
			
			[callBackExpectation fulfill];
		});
	}];
	
	[task resume];
	
	[self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
		if (error) {
			NSLog(@"%@", error);
		}
	}];
}

- (void)testBuildURLWithHardcodedQuery {
    DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
        builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
        builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
    }];

    NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];

    NSURLSessionDataTask* task = [service listReposDesc:@"natep" callback:^(NSArray *result, NSURLResponse *response, NSError *error) {}];

    NSArray* items = [[NSURLComponents alloc] initWithURL:task.originalRequest.URL resolvingAgainstBaseURL:NO].queryItems;
    XCTAssertEqual(items.count, 1);

    NSURLQueryItem* item = items.firstObject;

    XCTAssertEqualObjects(item.name, @"sort");
    XCTAssertEqualObjects(item.value, @"desc");
}

@end
