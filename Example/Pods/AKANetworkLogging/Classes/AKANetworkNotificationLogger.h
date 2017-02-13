//
//  AKANetworkNotificationLogger.h
//  AKANetworking
//
//  Created by Arlo Armstrong on 4/25/14.
//  Copyright (c) 2014 Arlo Armstrong. All rights reserved.
//

#import "AKANetworkLogger.h"

/**
 *  This class allows for logging based on observation of notifications sent when a network reqest starts and finishes. It can be customised by subclassing and overriding the methods determining which notifications are observed and how the network information is extracted from the notifications.
 *
 *  Logging is initiated in one of two ways:
 *
 *    1) Output logs for all notifications by using the sharedNetworkLogger:
 *       [AKANetworkNotificationLogger.sharedNetworkLogger startLogging];
 *
 *    2) Alternatively create instances of AKANetworkNotificationLogger and start each logging their own NSURLSessionTask.
 *       task.aka_networkLogger = [[AKANetworkNotificationLogger alloc] initWithLogOptions:AKANetworkLoggerOptionsDebugLevel];
 [task.aka_networkLogger startLoggingObject:task];
 *       
 *  The second method is more configurable because the networkLogger could have the verbosity of its output customised per call.
 *
 *  Note: to avoid double logging when the sharedNetworkLogger is enabled other instances of AKANetworkNotificationLogger will not output logs for the same notifications.
 */
@interface AKANetworkNotificationLogger : AKANetworkLogger


#pragma mark - Logging


/**
 *  Returns YES if logging is currently enabled
 */
@property (nonatomic, readonly, getter = isLogging) BOOL logging;


/**
 *  Only works if called on the sharedNetworkLogger. Equivalent to startLoggingObject:nil
 */
- (void)startLogging;


/**
 *  Starts observing the given object for start and finish notifications. Passing nil will observe all objects.
 *  To avoid accidentally logging the same object multiple times nil will be only respected when passed by the sharedNetworkLogger, all other instances must specify an object
 *
 *  @param object the object to observe for network start and finish notifications
 */
- (void)startLoggingObject:(id)object;


/**
 *  Stops logging and removes any notification observers.
 */
- (void)stopLogging;


#pragma mark - Override


/**
 *  Returns the name of the notification to listen for that indicates a network task has started. Defaults to NetworkTaskStartNotification, override as necessary.
 *
 *  @return the name of the notification to listen for that indicates a network task has started
 */
- (NSString *)nameForNetworkTaskStartNotification;
/**
 *  Returns the name of the notification to listen for that indicates a network task has finished. Defaults to NetworkTaskFinishedNotification, override as necessary. 
 *
 *  @return the name of the notification to listen for that indicates a network task has finished
 */
- (NSString *)nameForNetworkTaskFinishNotification;


/**
 *  Used to extract the NSURLRequest from a received network notification. Defaults to calling -[notification.object originalRequest]
 *
 *  @param notification the network notification being observed
 *
 *  @return the NSURLRequest from a received network notification
 */
- (NSURLRequest *)requestFromNetworkNotification:(NSNotification *)notification;
/**
 *  Used to extract the NSURLResponse from a received network notification. Defaults to calling -[notification.object response]
 *
 *  @param notification the network notification being observed
 *
 *  @return the NSURLResponse from a received network notification
 */
- (NSURLResponse *)responseFromNetworkNotification:(NSNotification *)notification;
/**
 *  Used to extract the NSData from a received network notification. Defaults to nil
 *
 *  @param notification the network notification being observed
 *
 *  @return the NSData from a received network notification
 */
- (NSData *)dataFromNetworkNotification:(NSNotification *)notification;
/**
 *  Used to extract the NSError from a received network notification. Defaults to calling -[notification.object error]
 *
 *  @param notification the network notification being observed
 *
 *  @return the NSError from a received network notification
 */
- (NSError *)errorFromNetworkNotification:(NSNotification *)notification;


@end
