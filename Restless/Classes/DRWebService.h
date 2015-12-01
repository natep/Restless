//
//  DRWebService.h
//  Restless
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#ifndef DRWebService_h
#define DRWebService_h

#ifdef DR_SWIFT_COMPAT
	#define DR_CALLBACK(type) (void (^ __nonnull)(type __nullable result, NSURLResponse * __nullable response, NSError* __nullable error))
#else
	#define DR_CALLBACK(type) (void (^)(type result, NSURLResponse *response, NSError* error))
#endif

#define GET(unused)		required
#define POST(unused)	required
#define DELETE(unused)	required
#define PUT(unused)		required
#define HEAD(unused)	required
#define PATCH(unused)	required

#define Body(unused)	required
#define Headers(...)	required

/**
 * All web services that you wish to build using DRRestAdapter should inherit from this protocol.
 */
@protocol DRWebService <NSObject>

@end

#endif /* DRWebService_h */
