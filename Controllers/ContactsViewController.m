//
//  ContactsViewController.m
//  Chatlenge
//
//  Created by lion on 6/11/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "AppDelegate.h"
#import "Globals.h"
#import "FriendRelation.h"
#import "HistoryData.h"
#import "ContactsViewController.h"
#import "MyProfileViewController.h"
#import "SearchUserViewController.h"
#import "UserProfileViewController.h"
#import "ChatlengeViewController.h"

#define kUsersTableViewCellID       @"FriendUsersTableViewCell"
#define kUserTableCellHeight        90.f

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive:) name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoteNotification:) name:kNotification_Remote_Notification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelfContactsReloaded:) name:kNotification_Self_Contacts_Reloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelfHistoryChanged:) name:kNotification_Self_History_Changed object:nil];
    
    [Globals setArrayFriendRelations:[[NSMutableArray alloc] init]];
    [Globals setDictionaryHistoryData:[[NSMutableDictionary alloc] init]];
    [self readFriendListAndHistoryData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _lblUsername.text = [Globals displayNameForUser:[PFUser currentUser]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Remote_Notification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Self_Contacts_Reloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Self_History_Changed object:nil];
    
    [Globals setArrayFriendRelations:nil];
    [Globals setDictionaryHistoryData:nil];
}

- (IBAction)onProfile:(id)sender
{
    MyProfileViewController *myProfileController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    [self.navigationController pushViewController:myProfileController animated:YES];
}

- (IBAction)onSearch:(id)sender
{
    SearchUserViewController *searchViewController = [[SearchUserViewController alloc] init];
    [self.navigationController pushViewController:searchViewController animated:YES];
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

// TableView delegate implementations
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    if (arrayFriendRelations == nil)
        return 0;
    else
        return arrayFriendRelations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    
    if (arrayFriendRelations == nil)
        return nil;
    
    FriendUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUsersTableViewCellID];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FriendUsersTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        cell.btnAvatar.layer.masksToBounds = YES;
        cell.btnAvatar.layer.cornerRadius = cell.btnAvatar.frame.size.width / 2;
    }
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:indexPath.row];
    HistoryData *historyData = [[Globals dictionaryHistoryData] objectForKey:friendRelation.relationId];
    PFUser *friendUser = friendRelation.friendUser;
    
    if (friendRelation.isAccepted == NO)
    {
        cell.imgStatus.image = [UIImage imageNamed:@"offline_mark.png"];
    }
    else
    {
        NSInteger onlineStatus = [friendUser[@"online_status"] integerValue];
        if ((onlineStatus & 1) == USER_OFFLINE)
        {
            cell.imgStatus.image = [UIImage imageNamed:@"offline_mark.png"];
        }
        else
        {
            onlineStatus = onlineStatus & (~1);
            if (onlineStatus == USER_AVAILABLE)
                cell.imgStatus.image = [UIImage imageNamed:@"online_mark.png"];
            else if (onlineStatus == USER_DONTDISTURB)
                cell.imgStatus.image = [UIImage imageNamed:@"busy_mark.png"];
            else if (onlineStatus == USER_AWAYFROM)
                cell.imgStatus.image = [UIImage imageNamed:@"away_mark.png"];
            else
                cell.imgStatus.image = [UIImage imageNamed:@"offline_mark.png"];
        }
    }
    
    NSString *fullname = friendUser[@"f_name"];
    if (fullname == nil || [fullname isEqualToString:@""])
        fullname = friendUser.username;
    cell.lblUsername.text = fullname;
    
    PFFile *photoFile = friendUser[@"photo"];
    if (photoFile == nil)
        [cell.btnAvatar setImage:[UIImage imageNamed:@"user_dummy.png"] forState:UIControlStateNormal];
    else if (photoFile.isDataAvailable)
        [cell.btnAvatar setImage:[UIImage imageWithData:[photoFile getData]] forState:UIControlStateNormal];
    else
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error != nil || data == nil)
                [cell.btnAvatar setImage:[UIImage imageNamed:@"user_dummy.png"] forState:UIControlStateNormal];
            else
                [cell.btnAvatar setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }];
    
    if (historyData == nil || historyData.lastMessage == nil)
    {
        cell.lblLastmessage.text = @"";
        cell.lblLasttime.text = @"";
    }
    else
    {
        NSInteger msgType = [historyData.lastMessage[@"msg_type"] integerValue];
        if (msgType == MEDIA_TEXT)
        {
            NSString *strMsg = historyData.lastMessage[@"msg_text"];
            if (strMsg == nil)
                cell.lblLastmessage.text = @"";
            else
                cell.lblLastmessage.text = strMsg;
        }
        else
            cell.lblLastmessage.text = [NSString stringWithFormat:@"%@ sent a photo message.", fullname];
        
        NSDate *lastMessageTime = historyData.lastMessage.updatedAt;
        cell.lblLasttime.text = [Globals stringOfTime:lastMessageTime];
        
    }
    
    cell.lblScore.text = [NSString stringWithFormat:@"%d", [friendUser[@"scores"] intValue]];
    if (historyData == nil)
        cell.lblChallenges.text = [NSString stringWithFormat:@"%ld", 0l];
    else
        cell.lblChallenges.text = [NSString stringWithFormat:@"%ld", historyData.unsolvedChallengeCount];
    
    BOOL isUnshown = NO;
    if (historyData != nil)
    {
        if (historyData.lastMessage == nil)
        {
        }
        else if (historyData.lastShownMessage == nil)
        {
            isUnshown = YES;
        }
        else
        {
            if (![historyData.lastShownMessage.objectId isEqualToString:historyData.lastMessage.objectId])
                isUnshown = YES;
        }
        if (historyData.lastChallenge == nil)
        {
        }
        else if (historyData.lastShownChallenge == nil)
        {
            isUnshown = YES;
        }
        else
        {
            if (![historyData.lastShownChallenge.objectId isEqualToString:historyData.lastChallenge.objectId])
                isUnshown = YES;
        }
    }
    if (isUnshown)
        cell.imgAccessory.image = [UIImage imageNamed:@"accessory1.png"];
    else
        cell.imgAccessory.image = [UIImage imageNamed:@"accessory2.png"];
    
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
    
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    
    if (arrayFriendRelations == nil)
        return;
    FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:indexPath.row];
    if (friendRelation == nil)
        return;
    
    if (friendRelation.isAccepted == NO)
    {
        UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        userProfileVC.selectedUser = friendRelation.friendUser;
        [self.navigationController pushViewController:userProfileVC animated:YES];
    }
    else
    {
        ChatlengeViewController *chatlengeVC = [[ChatlengeViewController alloc] initWithNibName:@"ChatlengeViewController" bundle:nil];
        chatlengeVC.selectedUser = friendRelation.friendUser;
        [self.navigationController pushViewController:chatlengeVC animated:YES];
        
    }
}

- (void)onAppBecomeActive:(NSNotification *)notification
{
    [self readFriendListAndHistoryData];
}

- (void)onRemoteNotification:(NSNotification *)notification
{
    NSDictionary *dictData = notification.userInfo;
    NSString *fromUserId = [dictData objectForKey:@"from_user"];
    NSInteger relationIndex = [self findIndexOfUserInFriendRelationList:fromUserId];
    
    int type = [[dictData objectForKey:@"type"] intValue];
    switch (type)
    {
        case NOTIFY_REQUEST_FRIEND:
        {
            if (relationIndex == -1)
            {
                PFQuery *queryFriend = [PFQuery queryWithClassName:@"friends"];
                [queryFriend whereKey:@"left_user" equalTo:[PFUser objectWithoutDataWithObjectId:fromUserId]];
                [queryFriend whereKey:@"right_user" equalTo:[PFUser currentUser]];
                [queryFriend includeKey:@"left_user"];
                [queryFriend findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error != nil ||
                        objects == nil ||
                        objects.count <= 0)
                        return;
                    PFObject *friendRelationObject = [objects objectAtIndex:0];
                    PFUser *friendUser = friendRelationObject[@"left_user"];
                    FriendRelation *friendRelation = [[FriendRelation alloc] init];
                    friendRelation.relationId = friendRelationObject.objectId;
                    friendRelation.friendUser = friendUser;
                    friendRelation.isRequested = NO;
                    friendRelation.isAccepted = NO;
                    [[Globals arrayFriendRelations] addObject:friendRelation];
                    
                    [_tableUsers reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Contacts_Reloaded object:nil];
                }];
            }
            break;
        }
        case NOTIFY_CANCEL_REQUEST:
        case NOTIFY_REJECT_REQUEST:
        case NOTIFY_REMOVE_FRIEND:
        {
            if (relationIndex != -1)
            {
                [[Globals arrayFriendRelations] removeObjectAtIndex:relationIndex];
                [_tableUsers reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Contacts_Reloaded object:nil];
            }
            break;
        }
        case NOTIFY_ACCEPT_REQUEST:
        {
            if (relationIndex != -1)
            {
                FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
                friendRelation.isAccepted = YES;
                [_tableUsers reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Contacts_Reloaded object:nil];
            }
            break;
        }
        case NOTIFY_INSTANT_MESSAGE:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Message_Received object:nil userInfo:dictData];
            
            if (relationIndex != -1)
            {
                FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
                
                NSString *messageId = [dictData objectForKey:@"message_id"];
                PFObject *messageObject = [PFObject objectWithoutDataWithClassName:@"chat_history" objectId:messageId];
                [messageObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (error != nil ||
                        object == nil)
                        return;
                    
                    NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
                    HistoryData *historyData = [dictionaryHistoryData objectForKey:friendRelation.relationId];
                    if (historyData == nil)
                        historyData = [[HistoryData alloc] init];
                    historyData.lastMessage = object;
                    [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
                    
                    [_tableUsers reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
                }];
            }
            
            break;
        }
        case NOTIFY_CHALLENGE_CHANGED:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
            
            if (relationIndex != -1)
            {
                FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
                [self readHistoryDataOfRelation:friendRelation];
            }
            
            break;
        }
    }
}

- (void)readFriendListAndHistoryData
{
    PFQuery *queryLeft = [PFQuery queryWithClassName:@"friends"];
    [queryLeft whereKey:@"left_user" equalTo:[PFUser currentUser]];
    
    PFQuery *queryRight = [PFQuery queryWithClassName:@"friends"];
    [queryRight whereKey:@"right_user" equalTo:[PFUser currentUser]];
    
    PFQuery *queryFriends = [PFQuery orQueryWithSubqueries:@[queryLeft, queryRight]];
    [queryFriends includeKey:@"left_user"];
    [queryFriends includeKey:@"right_user"];
    
    [queryFriends findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil || objects == nil)
        {
            NSLog(@"error occured in reading friend relations");
            return;
        }
        
        NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
        [arrayFriendRelations removeAllObjects];
        for (int i = 0; i < objects.count; i ++)
        {
            PFObject *friendRelationObject = [objects objectAtIndex:i];
            PFUser *leftUser = friendRelationObject[@"left_user"];
            PFUser *rightUser = friendRelationObject[@"right_user"];
            
            FriendRelation *friendRelation = [[FriendRelation alloc] init];
            
            friendRelation.relationId = friendRelationObject.objectId;
            if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
            {
                friendRelation.friendUser = rightUser;
                friendRelation.isRequested = YES;
            }
            else
            {
                friendRelation.friendUser = leftUser;
                friendRelation.isRequested = NO;
            }
            friendRelation.isAccepted = [friendRelationObject[@"accepted"] boolValue];
            
            [arrayFriendRelations addObject:friendRelation];
            [_tableUsers reloadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Contacts_Reloaded object:nil];
            
            [self readHistoryDataOfRelation:friendRelation];
        }
    }];
}

- (void)onAvatar:(NSInteger)index
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    
    if (arrayFriendRelations == nil)
        return;
    FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:index];
    if (friendRelation == nil)
        return;
    
    UserProfileViewController *userProfileVC = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
    userProfileVC.selectedUser = friendRelation.friendUser;
    [self.navigationController pushViewController:userProfileVC animated:YES];
}

- (void)onSelfContactsReloaded:(NSNotification *)notification
{
    [_tableUsers reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Contacts_Reloaded object:nil];
}

- (void)onSelfHistoryChanged:(NSNotification *)notification
{
    [_tableUsers reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
}

- (void)readHistoryDataOfRelation:(FriendRelation *)friendRelation
{
    // read last message
    PFQuery *subQuery1 = [PFQuery queryWithClassName:@"chat_history"];
    [subQuery1 whereKey:@"challenge" equalTo:[NSNull null]];
    PFQuery *subQuery2 = [PFQuery queryWithClassName:@"chat_history"];
    [subQuery2 whereKey:@"challenge" notEqualTo:[NSNull null]];
    [subQuery2 whereKey:@"challenge_solved" equalTo:@YES];
    PFQuery *queryLastMessage = [PFQuery orQueryWithSubqueries:@[subQuery1, subQuery2]];
    [queryLastMessage whereKey:@"from_user" equalTo:friendRelation.friendUser];
    [queryLastMessage whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryLastMessage includeKey:@"challenge"];
    [queryLastMessage setLimit:1];
    [queryLastMessage orderByDescending:@"updatedAt"];
    [queryLastMessage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
        HistoryData *historyData = [dictionaryHistoryData objectForKey:friendRelation.relationId];
        if (historyData == nil)
            historyData = [[HistoryData alloc] init];
        if (error != nil ||
            objects == nil ||
            objects.count <= 0)
            historyData.lastMessage = nil;
        else
            historyData.lastMessage = [objects objectAtIndex:0];
        [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
        [_tableUsers reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
    }];
    
    // read last challenge
    PFQuery *queryLastChallenge = [PFQuery queryWithClassName:@"challenge_history"];
    [queryLastChallenge whereKey:@"from_user" equalTo:friendRelation.friendUser];
    [queryLastChallenge whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryLastChallenge setLimit:1];
    [queryLastChallenge orderByDescending:@"updatedAt"];
    [queryLastChallenge findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
        HistoryData *historyData = [dictionaryHistoryData objectForKey:friendRelation.relationId];
        if (historyData == nil)
            historyData = [[HistoryData alloc] init];
        if (error != nil ||
            objects == nil ||
            objects.count <= 0)
            historyData.lastChallenge = nil;
        else
            historyData.lastChallenge = [objects objectAtIndex:0];
        [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
        [_tableUsers reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
    }];
    
    // read last shown message and challenge
    PFQuery *queryLastShownMessage = [PFQuery queryWithClassName:@"shown_chats"];
    [queryLastShownMessage whereKey:@"from_user" equalTo:friendRelation.friendUser];
    [queryLastShownMessage whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryLastShownMessage includeKey:@"shown_chat"];
    [queryLastShownMessage includeKey:@"shown_challenge"];
    [queryLastShownMessage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
        HistoryData *historyData = [dictionaryHistoryData objectForKey:friendRelation.relationId];
        if (historyData == nil)
            historyData = [[HistoryData alloc] init];
        if (error != nil ||
            objects == nil ||
            objects.count <= 0)
        {
            historyData.lastShownMessage = nil;
            historyData.lastShownChallenge = nil;
        }
        else
        {
            PFObject *shownChatsObject = [objects objectAtIndex:0];
            historyData.lastShownMessage = shownChatsObject[@"shown_chat"];
            historyData.lastShownChallenge = shownChatsObject[@"shown_challenge"];
        }
        [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
        [_tableUsers reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
    }];
    
    // get unsolved challenge count
    PFQuery *queryUnsolvedChallenges = [PFQuery queryWithClassName:@"challenge_history"];
    [queryUnsolvedChallenges whereKey:@"from_user" equalTo:friendRelation.friendUser];
    [queryUnsolvedChallenges whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryUnsolvedChallenges whereKey:@"phase" notEqualTo:[NSNumber numberWithInt:CHALLENGE_SOLVED]];
    [queryUnsolvedChallenges countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
        HistoryData *historyData = [dictionaryHistoryData objectForKey:friendRelation.relationId];
        if (historyData == nil)
            historyData = [[HistoryData alloc] init];
        if (error != nil)
            historyData.unsolvedChallengeCount = 0;
        else
            historyData.unsolvedChallengeCount = number;
        [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
        [_tableUsers reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HistoryData_Changed object:nil];
    }];
}

- (NSInteger)findIndexOfUserInFriendRelationList:(NSString *)friendId
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    if (arrayFriendRelations == nil)
        return -1;
    
    NSInteger index = -1;
    for (NSInteger i = 0; i < arrayFriendRelations.count; i ++)
    {
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        if ([friendRelation.friendUser.objectId isEqualToString:friendId])
        {
            index = i;
            break;
        }
    }
    return index;
}

@end
