//
//  DRSessionTaskProgressHandler.m
//  Restless
//
//  Created by Nate Petersen on 12/21/15.
//  Copyright © 2015 Digital Rickshaw LLC. All rights reserved.
//

#import "DRSessionTaskProgressHandler.h"

@interface DRSessionTaskProgressHandler ()

/*
 * This must be 'unsafe_unretained' instead of 'weak', or else it will be
 * nil when we try to unregister KVO in our own dealloc.
 */
@property(nonatomic,unsafe_unretained,readonly) NSURLSessionTask* task;

@end

@implementation DRSessionTaskProgressHandler

- (instancetype)initWithURLSessionTask:(NSURLSessionTask*)task
							   handler:(NSURLSessionTaskDownloadProgressHandler)handler
{
	self = [super init];
	
	if (self) {
		_handler = [handler copy];
		_task = task;
		
		[task addObserver:self forKeyPath:@"countOfBytesReceived" options:0 context:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[self.task removeObserver:self forKeyPath:@"countOfBytesReceived"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary<NSString*,id> *)change
					   context:(void *)context
{
	if (object == self.task && [keyPath isEqualToString:@"countOfBytesReceived"]) {
		self.handler(self.task.countOfBytesReceived, self.task.countOfBytesExpectedToReceive);
	}
}

@end
