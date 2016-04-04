//
//  DRMethodDescriptionTests.m
//  Restless
//
//  Created by Nate Petersen on 9/21/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DRMethodDescription.h"
#import "Restless.h"
#import "GitHubService.h"

@interface DRMethodDescriptionTests : XCTestCase

@end

@implementation DRMethodDescriptionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testResultSubtypeParsing
{
	DRMethodDescription* desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray<NSURL*>*" }];
	XCTAssertEqual([desc resultConversionClass], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray<NSURL *> *" }];
	XCTAssertEqual([desc resultConversionClass], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray *" }];
	XCTAssertNil([desc resultConversionClass]);
}

- (void)testHeaderParameterization
{
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	NSURLSessionUploadTask* task = [service updateProfilePic:[NSData data]
													   agent:@"test"
													callback:^(NSString *result, NSURLResponse *response, NSError *error) {}];
	
	NSDictionary* expectedHeaders = @{ @"Accept" : @"application/vnd.github.v3.full+json", @"User-Agent" : @"Sub: test" };
	NSDictionary* processedHeaders = task.originalRequest.allHTTPHeaderFields;
	
	XCTAssertEqualObjects(processedHeaders, expectedHeaders);
}

- (void)testQueryParameters
{
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	NSURLSessionUploadTask* task = [service updateProfilePic:[NSData data]
													   agent:@"test"
													  query1:@"firstQuery"
													  query2:@"secondQuery"
													callback:^(NSString *result, NSURLResponse *response, NSError *error) {}];
	
	NSURLComponents* comps = [NSURLComponents componentsWithURL:task.originalRequest.URL
										resolvingAgainstBaseURL:NO];
	
	NSArray* queryItems = comps.queryItems;
	
	XCTAssertEqual(queryItems.count, 2);
	
	NSURLQueryItem* item1 = queryItems.firstObject;
	XCTAssertEqualObjects(item1.name, @"query1");
	XCTAssertEqualObjects(item1.value, @"firstQuery");
	
	NSURLQueryItem* item2 = queryItems.lastObject;
	XCTAssertEqualObjects(item2.name, @"query2");
	XCTAssertEqualObjects(item2.value, @"secondQuery");
}

- (void)testFormURLEncodingAnnotation {
	
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	id service = [ra create:@protocol(GitHubService)];
	NSDictionary* descs = [service methodDescriptions];
	NSString* methodSig = NSStringFromSelector(@selector(submitName:age:formula:callback:));
	DRMethodDescription* desc = descs[methodSig];
	XCTAssertTrue([desc isFormURLEncoded]);
}

- (void)testFormURLEncoding {
	
	NSString* name = @"Gareth Wylie";
	NSUInteger age = 24;
	NSString* formula = @"a + b == 13%!";
	
	DRRestAdapter* ra = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
		builder.bundle = [NSBundle bundleForClass:[DRRestAdapter class]];
	}];
	
	NSObject<GitHubService>* service = [ra create:@protocol(GitHubService)];
	
	NSURLSessionDataTask* task = [service submitName:name age:age formula:formula callback:
								  ^(NSArray *result, NSURLResponse *response, NSError *error) {}];
	
	NSString* bodyString = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
	NSURL* tempURL = [NSURL URLWithString:[@"http://example.com?" stringByAppendingString:bodyString]];
	NSURLComponents* comps = [NSURLComponents componentsWithURL:tempURL resolvingAgainstBaseURL:NO];
	NSArray* queryItems = comps.queryItems;
	NSDictionary* queryDict = [NSDictionary dictionaryWithObjects:[queryItems valueForKey:@"value"]
														  forKeys:[queryItems valueForKey:@"name"]];
	
	XCTAssertEqualObjects(queryDict[@"name"], name);
	XCTAssertEqualObjects(queryDict[@"age"], @(age).stringValue);
	XCTAssertEqualObjects(queryDict[@"formula"], formula);
	
	XCTAssertEqualObjects([task.originalRequest valueForHTTPHeaderField:@"Content-Type"], @"application/x-www-form-urlencoded");
}

@end
