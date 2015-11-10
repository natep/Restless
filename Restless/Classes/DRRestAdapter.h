//
//  DRRestAdapter.h
//  Restless
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRConverterFactory;

/**
 * An error domain for reporting HTTP status code errors.
 */
extern NSString* const DRHTTPErrorDomain;

/**
 * A builder for DRRestAdapter.
 */
@interface DRRestAdapterBuilder : NSObject

/**
 * The base URL for the web service.
 */
@property(nonatomic,strong) NSURL* endPoint;

/**
 * The bundle where Restless' automatically generated files are located.
 * Defaults to the main bundle. Normally you do not need to set this property,
 * but it may be necessary when the bundle you are running is not the normal
 * app bundle, such as when running unit tests.
 */
@property(nonatomic,strong) NSBundle* bundle;

/**
 * The NSURLSession to be used by all instances of NSURLSessionTask generated
 * by the web service. Defaults to the shared session.
 */
@property(nonatomic,strong) NSURLSession* urlSession;

/**
 * A factory that creates converters, which are used to convert request parameters
 * and response data. By default uses DRJsonConverterFactory.
 */
@property(nonatomic,strong) id<DRConverterFactory> converterFactory;

@end

/**
 * A factory for building web service implementations from protocols.
 */
@interface DRRestAdapter : NSObject

/**
 * Creates a new DRRestAdapter using a builder block.
 */
+ (instancetype)restAdapterWithBlock:(void(^)(DRRestAdapterBuilder* builder))block;

/**
 * Constructs an implementation of the given protocol.
 *
 * @param protocol	The protocol to build. Must inherit from DRWebService.
 *
 * @return	Returns an object that implements the protocol.
 */
- (id)create:(Protocol*)protocol;

@end
