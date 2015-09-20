//
//  DRJsonConverterFactory.m
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/19/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRJsonConverterFactory.h"
#import "DRJsonConverter.h"

@implementation DRJsonConverterFactory

- (id<DRConverter>)converter
{
	return [[DRJsonConverter alloc] init];
}

@end
