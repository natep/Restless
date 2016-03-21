//
//  GitHubIssue.h
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Restless.h>

@interface GitHubIssue : NSObject <DRDictionaryConvertable>

@property(nonatomic,strong,readonly) NSString* title;
@property(nonatomic,strong,readonly) NSString* body;

@end
