//
//  DRRestAdapter.h
//  Restless
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRConverterFactory;

extern NSString* const DRHTTPErrorDomain;


@interface DRRestAdapterBuilder : NSObject

@property(nonatomic,strong) NSURL* endPoint;
@property(nonatomic,strong) NSBundle* bundle;
@property(nonatomic,strong) NSURLSession* urlSession;
@property(nonatomic,strong) id<DRConverterFactory> converterFactory;

@end

@interface DRRestAdapter : NSObject

+ (instancetype)restAdapterWithBlock:(void(^)(DRRestAdapterBuilder* builder))block;

- (id)create:(Protocol*)protocol;

@end
