//
//  RepoListViewController.h
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GitHubService.h"

@class GitHubRepo;

@interface RepoListViewController : UITableViewController

@property(nonatomic,strong) id<GitHubService> webService;
@property(nonatomic,strong) NSString* user;
@property(nonatomic,strong) NSArray<GitHubRepo*>* repos;

@end
