//
//  DRMethodDescription.h
//  Restless
//
//  Created by Nate Petersen on 9/3/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

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

- (NSString*)parameterizedPathForInvocation:(NSInvocation*)invocation withConverter:(id<DRConverter>)converter;

- (id)bodyForInvocation:(NSInvocation*)invocation withConverter:(id<DRConverter>)converter;

@end
