//
//  PickChallengeViewController.m
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "PickChallengeViewController.h"
#import "ChallengeCatViewController.h"

@interface PickChallengeViewController ()

@end

@implementation PickChallengeViewController

- (id)init
{
    ChallengeCatViewController *categoryVC = [[ChallengeCatViewController alloc] initWithNibName:@"ChallengeCatViewController" bundle:nil];
    self = [super initWithRootViewController:categoryVC];
    if (self) {
        self.navigationBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
