//
//  IssueListViewController.m
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import "IssueListViewController.h"
#import "GitHubIssue.h"

@interface IssueListViewController ()

@end

@implementation IssueListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.issues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	GitHubIssue* issue = self.issues[indexPath.row];
	
	cell.textLabel.text = issue.title;
	cell.detailTextLabel.text = issue.body;
	
    return cell;
}

@end
