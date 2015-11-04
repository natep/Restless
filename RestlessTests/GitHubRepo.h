//
//  GitHubRepo.h
//  Restless
//
//  Created by Nate Petersen on 9/21/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRDictionaryConvertable.h"

@interface GitHubRepo : NSObject <DRDictionaryConvertable>

@property(nonatomic,strong,readonly) NSString* name;
@property(nonatomic,strong,readonly) NSNumber* repoId;
@property(nonatomic,strong,readonly) NSURL* htmlURL;

@end
