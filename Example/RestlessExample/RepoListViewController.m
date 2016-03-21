//
//  RepoListViewController.m
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import "RepoListViewController.h"
#import "IssueListViewController.h"
#import "GitHubRepo.h"
#import "GitHubIssue.h"
#import "GitHubService.h"

@interface RepoListViewController ()

@property(nonatomic,strong) NSArray<GitHubIssue*>* issues;

@end

@implementation RepoListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	GitHubRepo* repo = self.repos[indexPath.row];
	
	cell.textLabel.text = repo.name;
	cell.detailTextLabel.text = repo.repoDescription;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	GitHubRepo* repo = self.repos[indexPath.row];
	
	// fetch issues from web service
	
	NSURLSessionDataTask* task = [self.webService listIssuesForUser:self.user
															   repo:repo.name
														   callback:
	^(NSArray<GitHubIssue *> *result, NSURLResponse *response, NSError *error) {
		self.issues = result;
		[self performSegueWithIdentifier:@"issueList" sender:self];
	}];
	
	[task resume];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"issueList"]) {
		IssueListViewController* vc = segue.destinationViewController;
		vc.issues = self.issues;
	}
}

@end
