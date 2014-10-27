//
//  UserProfileViewController.m
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "AppDelegate.h"
#import "Globals.h"
#import "FriendRelation.h"
#import "UserProfileViewController.h"
#import "ChatlengeViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

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
    
    _imgUserphoto.layer.masksToBounds = YES;
    _imgUserphoto.layer.cornerRadius = 50.f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactsReloaded:) name:kNotification_Contacts_Reloaded object:nil];
    
    [self contactsReloaded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Contacts_Reloaded object:nil];
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

- (IBAction)onSendContact:(id)sender
{
    PFObject *friendRelationObject = [PFObject objectWithClassName:@"friends"];
    friendRelationObject[@"left_user"] = [PFUser currentUser];
    friendRelationObject[@"right_user"] = _selectedUser;
    friendRelationObject[@"accepted"] = [NSNumber numberWithBool:NO];
    [friendRelationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil ||
            succeeded == NO)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Contact" message:@"Error occured during adding contact." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        else
        {
            NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
            FriendRelation *friendRelation = [[FriendRelation alloc] init];
            friendRelation.relationId = friendRelationObject.objectId;
            friendRelation.friendUser = _selectedUser;
            friendRelation.isRequested = YES;
            friendRelation.isAccepted = NO;
            [arrayFriendRelations addObject:friendRelation];
            
            NSString *fullname = [PFUser currentUser][@"f_name"];
            if (fullname == nil)
                fullname = [PFUser currentUser].username;
            NSString *pushMessage = [NSString stringWithFormat:@"%@ wants to add you as a friend.", fullname];
            [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_REQUEST_FRIEND withCustomData:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_Contacts_Reloaded object:nil];
        }
    }];
}

- (IBAction)onResendContact:(id)sender
{
    NSString *fullname = [PFUser currentUser][@"f_name"];
    if (fullname == nil)
        fullname = [PFUser currentUser].username;
    NSString *pushMessage = [NSString stringWithFormat:@"%@ wants to add you as a friend.", fullname];
    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_REQUEST_FRIEND withCustomData:nil];
}

- (IBAction)onCancelRequest:(id)sender
{
    [self deleteFriendRelationRecord];
    
    NSString *fullname = [PFUser currentUser][@"f_name"];
    if (fullname == nil)
        fullname = [PFUser currentUser].username;
    NSString *pushMessage = [NSString stringWithFormat:@"%@ cancelled the friend request.", fullname];
    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_CANCEL_REQUEST withCustomData:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_Contacts_Reloaded object:nil];
}

- (IBAction)onAcceptRequest:(id)sender
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    NSString *relationId = nil;
    for (int i = 0; i < arrayFriendRelations.count; i ++)
    {
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        if ([_selectedUser.objectId isEqualToString:friendRelation.friendUser.objectId])
        {
            relationId = friendRelation.relationId;
            friendRelation.isAccepted = YES;
            break;
        }
    }
    if (relationId == nil)
        return;
    
    PFObject *friendRelationObject = [PFObject objectWithoutDataWithClassName:@"friends" objectId:relationId];
    friendRelationObject[@"accepted"] = [NSNumber numberWithBool:YES];
    [friendRelationObject saveEventually];
    
    NSString *fullname = [PFUser currentUser][@"f_name"];
    if (fullname == nil)
        fullname = [PFUser currentUser].username;
    NSString *pushMessage = [NSString stringWithFormat:@"%@ accepted the friend request.", fullname];
    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_ACCEPT_REQUEST withCustomData:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_Contacts_Reloaded object:nil];
}

- (IBAction)onRejectRequest:(id)sender
{
    [self deleteFriendRelationRecord];
    
    NSString *fullname = [PFUser currentUser][@"f_name"];
    if (fullname == nil)
        fullname = [PFUser currentUser].username;
    NSString *pushMessage = [NSString stringWithFormat:@"%@ rejected the friend request.", fullname];
    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_REJECT_REQUEST withCustomData:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_Contacts_Reloaded object:nil];
}

- (IBAction)onMessageTo:(id)sender
{
    ChatlengeViewController *chatlengeVC = [[ChatlengeViewController alloc] initWithNibName:@"ChatlengeViewController" bundle:nil];
    chatlengeVC.selectedUser = _selectedUser;
    [self.navigationController pushViewController:chatlengeVC animated:YES];
}

- (IBAction)onRemoveContact:(id)sender
{
    [self deleteFriendRelationRecord];
    
    NSString *fullname = [PFUser currentUser][@"f_name"];
    if (fullname == nil)
        fullname = [PFUser currentUser].username;
    NSString *pushMessage = [NSString stringWithFormat:@"%@ removed you from the friend list.", fullname];
    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:pushMessage withType:NOTIFY_REMOVE_FRIEND withCustomData:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_Contacts_Reloaded object:nil];
}

- (void)contactsReloaded
{
    _lblUsername.text = _selectedUser.username;
    PFFile *photoFile = _selectedUser[@"photo"];
    if (photoFile == nil)
        _imgUserphoto.image = [UIImage imageNamed:@"user_dummy.png"];
    else if (photoFile.isDataAvailable)
        _imgUserphoto.image = [UIImage imageWithData:[photoFile getData]];
    else
    {
        _imgUserphoto.image = [UIImage imageNamed:@"user_dummy.png"];
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data == nil || error != nil)
                _imgUserphoto.image = [UIImage imageNamed:@"user_dummy.png"];
            else
                _imgUserphoto.image = [UIImage imageWithData:data];
        }];
    }
    _lblUserscore.text = [NSString stringWithFormat:@"%d", [_selectedUser[@"scores"] intValue]];
    int online_status = [_selectedUser[@"online_status"] intValue];
    NSInteger friendIndex = [self findIndexOfUserInFriendRelationList];
    if (friendIndex == -1)
    {
        _imgUserstatus.image = [UIImage imageNamed:@"offline_mark.png"];
        _lblUserstatus.text = @"Offline";
    }
    else
    {
        FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:friendIndex];
        if (friendRelation.isAccepted == NO)
        {
            _imgUserstatus.image = [UIImage imageNamed:@"offline_mark.png"];
            _lblUserstatus.text = @"Offline";
        }
        else if ((online_status & 1) == USER_OFFLINE)
        {
            _imgUserstatus.image = [UIImage imageNamed:@"offline_mark.png"];
            _lblUserstatus.text = @"Offline";
        }
        else
        {
            online_status = online_status & (~1);
            if (online_status == USER_AVAILABLE)
            {
                _imgUserstatus.image = [UIImage imageNamed:@"online_mark.png"];
                _lblUserstatus.text = @"Online";
            }
            else if (online_status == USER_DONTDISTURB)
            {
                _imgUserstatus.image = [UIImage imageNamed:@"busy_mark.png"];
                _lblUserstatus.text = @"Busy";
            }
            else if (online_status == USER_AWAYFROM)
            {
                _imgUserstatus.image = [UIImage imageNamed:@"away_mark.png"];
                _lblUserstatus.text = @"Away";
            }
            else
            {
                _imgUserstatus.image = [UIImage imageNamed:@"offline_mark.png"];
                _lblUserstatus.text = @"Offline";
            }
        }
    }
    NSString *fullname = _selectedUser[@"f_name"];
    if (fullname == nil)
        _lblUserFullname.text = @"";
    else
        _lblUserFullname.text = fullname;
    
    if (friendIndex == -1)
    {
        _viewSendContact.hidden = NO;
        _viewResendCancel.hidden = YES;
        _viewAcceptReject.hidden = YES;
        _viewMessageRemove.hidden = YES;
    }
    else
    {
        FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:friendIndex];
        if (friendRelation.isAccepted)
        {
            _viewSendContact.hidden = YES;
            _viewResendCancel.hidden = YES;
            _viewAcceptReject.hidden = YES;
            _viewMessageRemove.hidden = NO;
        }
        else if (friendRelation.isRequested)
        {
            _viewSendContact.hidden = YES;
            _viewResendCancel.hidden = NO;
            _viewAcceptReject.hidden = YES;
            _viewMessageRemove.hidden = YES;
        }
        else
        {
            _viewSendContact.hidden = YES;
            _viewResendCancel.hidden = YES;
            _viewAcceptReject.hidden = NO;
            _viewMessageRemove.hidden = YES;
        }
    }
}
    
- (NSInteger)findIndexOfUserInFriendRelationList
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    if (arrayFriendRelations == nil)
        return -1;
    
    NSInteger index = -1;
    for (NSInteger i = 0; i < arrayFriendRelations.count; i ++)
    {
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        if ([friendRelation.friendUser.objectId isEqualToString:_selectedUser.objectId])
        {
            index = i;
            break;
        }
    }
    return index;
}

- (void)onContactsReloaded:(NSNotification *)notification
{
    [self contactsReloaded];
}

- (void)deleteFriendRelationRecord
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    NSString *relationId = nil;
    for (int i = 0; i < arrayFriendRelations.count; i ++)
    {
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        if ([_selectedUser.objectId isEqualToString:friendRelation.friendUser.objectId])
        {
            relationId = friendRelation.relationId;
            [arrayFriendRelations removeObjectAtIndex:i];
            break;
        }
    }
    if (relationId == nil)
        return;
    
    PFObject *friendRelationObject = [PFObject objectWithoutDataWithClassName:@"friends" objectId:relationId];
    [friendRelationObject deleteEventually];
}

@end
