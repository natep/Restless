//
//  DRSessionTaskProgressHandler.h
//  Restless
//
//  Created by Nate Petersen on 12/21/15.
//  Copyright © 2015 Digital Rickshaw LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionTask+DRProgressHandler.h"

@interface DRSessionTaskProgressHandler : NSObject

@property(nonatomic,strong,readonly) NSURLSessionTaskDownloadProgressHandler handler;

- (instancetype)initWithURLSessionTask:(NSURLSessionTask*)task
							   handler:(NSURLSessionTaskDownloadProgressHandler)handler;

@end
