//
//  DRParameterizeResult.h
//  Restless
//
//  Created by Nate Petersen on 11/5/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRParameterizeResult<ObjectType> : NSObject

@property(nonatomic,strong,readonly) ObjectType result;
@property(nonatomic,strong,readonly) NSSet* consumedParameters;

- (instancetype)initWithResult:(ObjectType)result
			consumedParameters:(NSSet<NSString*>*)consumedParameters;

@end
