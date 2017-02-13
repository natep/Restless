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
extern NSString* __nonnull const DRHTTPErrorDomain;

/**
 *  NSNotification name for http requests.
 */
extern NSString* __nonnull const DRHTTPRequestNotification;

/**
 *  NSNotification name for http response.
 */
extern NSString* __nonnull const DRHTTPResponseNotification;

/**
 *  NSNotification user info key for http request.
 */
extern NSString* __nonnull const DRHTTPRequestKey;

/**
 *  NSNotification user info key for http error.
 */
extern NSString* __nonnull const DRHTTPErrorKey;

/**
 *  NSNotification user info key for http response.
 */
extern NSString* __nonnull const DRHTTPResponseKey;

/**
 *  NSNotification user info key for http response data.
 */
extern NSString* __nonnull const DRHTTPResponseDataKey;


/**
 * A builder for DRRestAdapter.
 */
@interface DRRestAdapterBuilder : NSObject

/**
 * The base URL for the web service.
 */
@property(nonatomic,strong,nullable) NSURL* endPoint;

/**
 * The bundle where Restless' automatically generated files are located.
 * Defaults to the main bundle. Normally you do not need to set this property,
 * but it may be necessary when the bundle you are running is not the normal
 * app bundle, such as when running unit tests.
 */
@property(nonatomic,strong,nullable) NSBundle* bundle;

/**
 * The NSURLSession to be used by all instances of NSURLSessionTask generated
 * by the web service. Defaults to the shared session.
 */
@property(nonatomic,strong,nullable) NSURLSession* urlSession;

/**
 * A factory that creates converters, which are used to convert request parameters
 * and response data. By default uses DRJsonConverterFactory.
 */
@property(nonatomic,strong,nullable) id<DRConverterFactory> converterFactory;


/**
 * A Flag indicating if this instance supports notification for logging purposes
 */
@property(nonatomic,readwrite) BOOL notificationEnabled;

@end

/**
 * A factory for building web service implementations from protocols.
 */
@interface DRRestAdapter : NSObject

/**
 * Creates a new DRRestAdapter using a builder block.
 */
+ (instancetype __nonnull)restAdapterWithBlock:(void(^ __nonnull)(DRRestAdapterBuilder* __nonnull builder))block;

/**
 * Constructs an implementation of the given protocol.
 *
 * @param protocol	The protocol to build. Must inherit from DRWebService.
 *
 * @return	Returns an object that implements the protocol.
 */
- (id __nonnull)create:(Protocol* __nonnull)protocol;

@end
