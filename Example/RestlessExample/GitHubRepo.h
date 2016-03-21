//
//  GitHubRepo.h
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restless.h>

@interface GitHubRepo : NSObject <DRDictionaryConvertable>

@property(nonatomic,strong,readonly) NSString* name;
@property(nonatomic,strong,readonly) NSString* repoDescription;

@end
