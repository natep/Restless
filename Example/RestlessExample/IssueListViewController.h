//
//  IssueListViewController.h
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GitHubIssue;

@interface IssueListViewController : UITableViewController

@property(nonatomic,strong) NSArray<GitHubIssue*>* issues;

@end
