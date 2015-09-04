//
//  DRProtocolImpl.h
//  WebServiceProtocol
//
//  Created by Nate Petersen on 8/31/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRProtocolImpl : NSObject

@property(nonatomic,strong) Protocol* protocol;
@property(nonatomic,strong) NSURL* endPoint;
@property(nonatomic,strong) NSDictionary* methodDescriptions;

@end
