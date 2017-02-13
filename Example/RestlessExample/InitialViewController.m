//
//  InitialViewController.m
//  RestlessExample
//
//  Created by Nate Petersen on 1/11/16.
//  Copyright © 2016 Digital Rickshaw LLC. All rights reserved.
//

#import "InitialViewController.h"
#import "RepoListViewController.h"
#import "GitHubRepo.h"
#import "GitHubService.h"

@interface InitialViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textfield;

@property(nonatomic,strong) NSArray<GitHubRepo*>* repos;
@property(nonatomic,strong) id<GitHubService> webService;

@end

@implementation InitialViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// create the web service
	
	DRRestAdapter* adapter = [DRRestAdapter restAdapterWithBlock:^(DRRestAdapterBuilder *builder) {
		builder.endPoint = [NSURL URLWithString:@"https://api.github.com"];
        
        //for logger support
        builder.notificationEnabled = YES;
		
		// we'll create a custom URL session so that the callbacks happen on the main thread
		builder.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
														   delegate:nil
													  delegateQueue:[NSOperationQueue mainQueue]];
	}];
	
	self.webService = [adapter create:@protocol(GitHubService)];
}

- (IBAction)getReposPressed:(id)sender
{
	// fetch repos from web service
	
	NSURLSessionDataTask* task = [self.webService listRepos:self.textfield.text callback:
		^(NSArray<GitHubRepo *> *result, NSURLResponse *response, NSError *error) {
			self.repos = result;
			[self performSegueWithIdentifier:@"repoList" sender:self];
		}
	];
	
	[task resume];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"repoList"]) {
		RepoListViewController* vc = segue.destinationViewController;
		vc.webService = self.webService;
		vc.user = self.textfield.text;
		vc.repos = self.repos;
	}
}

@end
