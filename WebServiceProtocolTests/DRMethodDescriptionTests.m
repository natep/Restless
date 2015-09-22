//
//  DRMethodDescriptionTests.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/21/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DRMethodDescription.h"

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
	XCTAssertEqual([desc resultSubtype], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray<NSURL *> *" }];
	XCTAssertEqual([desc resultSubtype], [NSURL class]);
	
	desc = [[DRMethodDescription alloc] initWithDictionary:@{ @"resultType" : @"NSArray *" }];
	XCTAssertNil([desc resultSubtype]);
}

@end
