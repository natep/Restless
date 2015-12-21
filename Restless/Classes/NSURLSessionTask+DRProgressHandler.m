//
//  NSURLSessionTask+DRProgressHandler.m
//  Restless
//
//  Created by Nate Petersen on 12/21/15.
//  Copyright © 2015 Digital Rickshaw LLC. All rights reserved.
//

#import "NSURLSessionTask+DRProgressHandler.h"
#import <objc/runtime.h>
#import "DRSessionTaskProgressHandler.h"

@implementation NSURLSessionTask (DRProgressHandler)

- (void)setDownloadProgressHandler:(NSURLSessionTaskDownloadProgressHandler)downloadProgressHandler
{
	DRSessionTaskProgressHandler* wrapper = [[DRSessionTaskProgressHandler alloc] initWithURLSessionTask:self
																								 handler:downloadProgressHandler];
	
	objc_setAssociatedObject(self, @selector(downloadProgressHandler), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionTaskDownloadProgressHandler)downloadProgressHandler
{
	DRSessionTaskProgressHandler* wrapper = objc_getAssociatedObject(self, @selector(downloadProgressHandler));
	return wrapper.handler;
}

@end
