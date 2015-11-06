//
//  DRParameterizeResult.m
//  Restless
//
//  Created by Nate Petersen on 11/5/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import "DRParameterizeResult.h"

@implementation DRParameterizeResult

- (instancetype)initWithResult:(id)result
			consumedParameters:(NSSet<NSString*>*)consumedParameters
{
	self = [super init];
	
	if (self) {
		_result = result;
		_consumedParameters = consumedParameters.copy;
	}
	
	return self;
}

@end
