//
//  NSURLSessionTask+DRProgressHandler.h
//  Restless
//
//  Created by Nate Petersen on 12/21/15.
//  Copyright © 2015 Digital Rickshaw LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSURLSessionTaskDownloadProgressHandler)(int64_t received, int64_t expected);

/**
 * Adds a download progress callback to NSURLSession.
 */
@interface NSURLSessionTask (DRProgressHandler)

/**
 * Sets a download progress callback. The callback will be executed whenever additional data is downloaded.
 */
- (void)setDownloadProgressHandler:(NSURLSessionTaskDownloadProgressHandler)downloadProgressHandler;

/**
 * Returns the progress handler currently associated with the session.
 *
 * @see	setDownloadProgressHandler:
 */
- (NSURLSessionTaskDownloadProgressHandler)downloadProgressHandler;

@end
