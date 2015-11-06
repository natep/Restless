//
//  DRMethodDescription.h
//  Restless
//
//  Created by Nate Petersen on 9/3/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRParameterizeResult.h"

@protocol DRConverter;

@interface DRMethodDescription : NSObject

@property(nonatomic,strong,readonly) NSArray* parameterNames;
@property(nonatomic,strong,readonly) NSString* resultType;
@property(nonatomic,strong,readonly) NSDictionary* annotations;
@property(nonatomic,strong,readonly) NSString* taskType;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSString*)httpMethod;

- (Class)taskClass;

- (Class)resultSubtype;

- (DRParameterizeResult<NSString*>*)parameterizedPathForInvocation:(NSInvocation*)invocation
													 withConverter:(id<DRConverter>)converter;

- (DRParameterizeResult<NSDictionary*>*)parameterizedHeadersForInvocation:(NSInvocation*)invocation
														withConverter:(id<DRConverter>)converter;

- (DRParameterizeResult*)bodyForInvocation:(NSInvocation*)invocation
							 withConverter:(id<DRConverter>)converter;

@end
