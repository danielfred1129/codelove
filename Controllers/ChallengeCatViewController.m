//
//  ChallengeCatViewController.m
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"
#import "ChallengeCatViewController.h"
#import "ChallengeCatTableViewCell.h"
#import "PickChallengeViewController.h"
#import "ChallengeEditViewController.h"

@interface ChallengeCatViewController ()

@end

@implementation ChallengeCatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imgUserPhoto.layer.masksToBounds = YES;
    _imgUserPhoto.layer.cornerRadius = 35.f;
    
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    PFUser *selectedUser = pickController.selectedUser;
    _lblUsername.text = [Globals displayNameForUser:selectedUser];
    PFFile *photoFile = selectedUser[@"photo"];
    if (photoFile == nil)
        _imgUserPhoto.image = [UIImage imageNamed:@"user_dummy.png"];
    else if (photoFile.isDataAvailable)
        _imgUserPhoto.image = [UIImage imageWithData:[photoFile getData]];
    else
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            _imgUserPhoto.image = [UIImage imageWithData:data];
        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction)onBack:(id)sender
{
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    if (pickController.delegate != nil &&
        [pickController.delegate respondsToSelector:@selector(didCancelPickingChallenge)])
        [pickController.delegate didCancelPickingChallenge];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChallengeCatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChallengeCatTableViewCell"];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeCatTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    if (indexPath.row == 0)
    {
        cell.imgCategory.image = [UIImage imageNamed:@"q_challenge_in_mark.png"];
        cell.lblCategory.text = @"Question";
    }
    else if (indexPath.row == 1)
    {
        cell.imgCategory.image = [UIImage imageNamed:@"e_challenge_in_mark.png"];
        cell.lblCategory.text = @"Evidence";
    }
    else if (indexPath.row == 2)
    {
        cell.imgCategory.image = [UIImage imageNamed:@"d_challenge_in_mark.png"];
        cell.lblCategory.text = @"Date";
    }
    else
    {
        cell.imgCategory.image = nil;
        cell.lblCategory.text = nil;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChallengeEditViewController *editVC = [[ChallengeEditViewController alloc] initWithNibName:@"ChallengeEditViewController" bundle:nil];
    if (indexPath.row == 0)
        editVC.challengeType = QUEST_CHALLENGE;
    else if (indexPath.row == 1)
        editVC.challengeType = EVID_CHALLENGE;
    else
        editVC.challengeType = DATE_CHALLENGE;
    [self.navigationController pushViewController:editVC animated:YES];
}

@end
