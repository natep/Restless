//
//  DRWebService.h
//  Restless
//
//  Created by Nate Petersen on 8/27/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#ifndef DRWebService_h
#define DRWebService_h

#define DR_CALLBACK(type) (void (^)(type result, NSURLResponse *response, NSError* error))

#define GET(unused)		required
#define POST(unused)	required
#define DELETE(unused)	required
#define PUT(unused)		required
#define HEAD(unused)	required
#define PATCH(unused)	required

#define Body(unused)	required
#define Headers(...)	required


@protocol DRWebService <NSObject>

@end

#endif /* DRWebService_h */
