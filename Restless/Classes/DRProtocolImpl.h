//
//  DRProtocolImpl.h
//  Restless
//
//  Created by Nate Petersen on 8/31/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DRConverterFactory;

@interface DRProtocolImpl : NSObject

@property(nonatomic,strong) Protocol* protocol;
@property(nonatomic,strong) NSURL* endPoint;
@property(nonatomic,strong) NSURLSession* urlSession;
@property(nonatomic,strong) NSDictionary* methodDescriptions;
@property(nonatomic,strong) id<DRConverterFactory> converterFactory;
@property(nonatomic) BOOL notificationEnabled;

@end
