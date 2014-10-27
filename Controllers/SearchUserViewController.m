//
//  SearchViewController.m
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "SearchUserViewController.h"
#import "SearchUsersTableViewCell.h"
#import "UserProfileViewController.h"

#define kUsersTableViewCellID       @"SearchUsersTableViewCell"
#define kUserTableCellHeight        60.f

@interface SearchUserViewController ()

@end

@implementation SearchUserViewController

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
    
    [_searchBar setShowsCancelButton:NO animated:NO];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *strSearchKey = searchBar.text;
    [self searchUsers:strSearchKey];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar resignFirstResponder];
}

// TableView delegate implementations
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arraySearchedUsers == nil)
        return 0;
    else
        return arraySearchedUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arraySearchedUsers == nil)
        return nil;
    
    SearchUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUsersTableViewCellID];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchUsersTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.tag = indexPath.row;
    
    PFUser *userObject = [arraySearchedUsers objectAtIndex:indexPath.row];
    
    NSString *fullname = userObject[@"f_name"];
    if (fullname == nil ||
        [fullname isEqualToString:@""])
        cell.lblFullname.text = userObject.username;
    else
        cell.lblFullname.text = fullname;
    cell.lblUsername.text = userObject.username;
    cell.lblScore.text = [NSString stringWithFormat:@"%d", [userObject[@"scores"] intValue]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kUserTableCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (arraySearchedUsers == nil)
        return;
    PFUser *user = [arraySearchedUsers objectAtIndex:indexPath.row];
    
    UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
    userProfileVC.selectedUser = user;
    [self.navigationController pushViewController:userProfileVC animated:YES];
}

- (void)searchUsers:(NSString *)searchKey
{
    if (searchKey == nil ||
        [searchKey isEqualToString:@""])
        return;
    
    PFQuery *queryUsers1 = [PFUser query];
    [queryUsers1 whereKey:@"f_name_l" containsString:searchKey];
    PFQuery *queryUsers2 = [PFUser query];
    [queryUsers2 whereKey:@"username_l" containsString:searchKey];
    PFQuery *queryUsers = [PFQuery orQueryWithSubqueries:@[queryUsers1, queryUsers2]];
    [queryUsers whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil || objects == nil)
            return;
        arraySearchedUsers = objects;
        [_tableUsers reloadData];
    }];
}

@end
