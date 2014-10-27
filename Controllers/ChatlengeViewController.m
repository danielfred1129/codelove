//
//  ChatlengeViewController.m
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"
#import "FriendRelation.h"
#import "HistoryData.h"
#import "ChatlengeViewController.h"

@interface ChatlengeViewController ()

@end

@implementation ChatlengeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentScreen = 0;
        isOthersChanges = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *fullname = _selectedUser[@"f_name"];
    if (fullname == nil)
        fullname = _selectedUser.username;
    _lblUsername.text = fullname;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactsReloaded:) name:kNotification_Contacts_Reloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHistoryChanged:) name:kNotification_HistoryData_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLinkMessage:) name:kNotification_Link_Message object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLinkChallenge:) name:kNotification_Link_Challenge object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCreditsChanged:) name:kNotification_Credits_Changed object:nil];
    
    messageViewController = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
    messageViewController.selectedUser = _selectedUser;
    messageViewController.superViewController = self;
    [messageViewController view];
    challengeViewController = [[ChallengeViewController alloc] initWithNibName:@"ChallengeViewController" bundle:nil];
    challengeViewController.selectedUser = _selectedUser;
    challengeViewController.superViewController = self;
    [challengeViewController view];
    
    _imgUserPhoto.layer.masksToBounds = YES;
    _imgUserPhoto.layer.cornerRadius = 35.f;
    PFFile *photoFile = _selectedUser[@"photo"];
    if (photoFile == nil)
        _imgUserPhoto.image = [UIImage imageNamed:@"user_dummy.png"];
    else if (photoFile.isDataAvailable)
        _imgUserPhoto.image = [UIImage imageWithData:[photoFile getData]];
    else
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error != nil ||
                data == nil)
                _imgUserPhoto.image = [UIImage imageNamed:@"user_dummy.png"];
            else
                _imgUserPhoto.image = [UIImage imageWithData:data];
        }];
    
    unshownMessageBadge = [CustomBadge customBadgeWithString:@"" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor colorWithRed:.737f green:.804f blue:.165f alpha:1.f] withBadgeFrame:NO withBadgeFrameColor:[UIColor clearColor] withScale:1.f withShining:NO];
    unshownMessageBadge.frame = CGRectMake(0, 0, 30, 30);
    [_viewUnshownMsgContainer addSubview:unshownMessageBadge];
    unsolvedChallengeBadge = [CustomBadge customBadgeWithString:@"" withStringColor:[UIColor whiteColor] withInsetColor:[UIColor colorWithRed:.176f green:.722f blue:.835f alpha:1.f] withBadgeFrame:NO withBadgeFrameColor:[UIColor clearColor] withScale:1.f withShining:NO];
    unsolvedChallengeBadge.frame = CGRectMake(0, 0, 30, 30);
    [_viewUnsolvedChlContainer addSubview:unsolvedChallengeBadge];
    
    isOthersChanges = NO;
    _btnBack.selected = isOthersChanges;
    
    _lblLastMessageTime.text = @"";
    _lblUnlockCount.text = [NSString stringWithFormat:@"%d", [[PFUser currentUser][@"credits"] intValue]];
    
    currentScreen = 0;
    _btnMessage.selected = YES;
    _btnChallenge.selected = NO;
    [self removeAllSubViewsInView:_viewContainer];
    messageViewController.isShown = YES;
    challengeViewController.isShown = NO;
    messageViewController.view.frame = _viewContainer.bounds;
    [_viewContainer addSubview:messageViewController.view];
    
    [self updateReminders:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Contacts_Reloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_HistoryData_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Link_Message object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Link_Challenge object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Credits_Changed object:nil];
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
    messageViewController.isShown = NO;
    challengeViewController.isShown = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMessage:(id)sender
{
    if (currentScreen == 0)
        return;
    
    currentScreen = 0;
    _btnMessage.selected = YES;
    _btnChallenge.selected = NO;
    [self removeAllSubViewsInView:_viewContainer];
    messageViewController.isShown = YES;
    challengeViewController.isShown = NO;
    messageViewController.view.frame = _viewContainer.bounds;
    [_viewContainer addSubview:messageViewController.view];
}

- (IBAction)onChallenge:(id)sender
{
    if (currentScreen == 1)
        return;
    
    currentScreen = 1;
    _btnMessage.selected = NO;
    _btnChallenge.selected = YES;
    [self removeAllSubViewsInView:_viewContainer];
    messageViewController.isShown = NO;
    challengeViewController.isShown = YES;
    challengeViewController.view.frame = _viewContainer.bounds;
    [_viewContainer addSubview:challengeViewController.view];
}

- (void)onContactsReloaded:(NSNotification *)notification
{
    isOthersChanges = YES;
    _btnBack.selected = isOthersChanges;
}

- (void)onHistoryChanged:(NSNotification *)notification
{
    [self updateReminders:NO];
}

- (void)onLinkMessage:(NSNotification *)notification
{
    [self onMessage:nil];
}

- (void)onLinkChallenge:(NSNotification *)notification
{
    [self onChallenge:nil];
}

- (void)onCreditsChanged:(NSNotification *)notification
{
    _lblUnlockCount.text = [NSString stringWithFormat:@"%d", [[PFUser currentUser][@"credits"] intValue]];
}

- (void)updateReminders:(BOOL)isInitial
{
    NSInteger relationIndex = [self findIndexOfUserInFriendRelationList:_selectedUser.objectId];
    if (relationIndex == -1)
    {
        [unshownMessageBadge setBadgeText:@""];
        [unsolvedChallengeBadge setBadgeText:@""];
        if (!isInitial)
        {
            isOthersChanges = YES;
            _btnBack.selected = isOthersChanges;
        }
        _lblLastMessageTime.text = @"";
        return;
    }
    
    FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
    HistoryData *historyData = [[Globals dictionaryHistoryData] objectForKey:friendRelation.relationId];
    if (historyData == nil)
    {
        [unshownMessageBadge setBadgeText:@""];
        [unsolvedChallengeBadge setBadgeText:@""];
        if (!isInitial)
        {
            isOthersChanges = YES;
            _btnBack.selected = isOthersChanges;
        }
        _lblLastMessageTime.text = @"";
        return;
    }
    
    if (historyData.lastMessage == nil)
    {
        unshownMessageBadge.badgeText = @"";
    }
    else
    {
        if (historyData.lastShownMessage != nil &&
            [historyData.lastMessage.objectId isEqualToString:historyData.lastShownMessage.objectId])
        {
            unshownMessageBadge.badgeText = @"";
        }
        else
        {
            PFQuery *subQuery1 = [PFQuery queryWithClassName:@"chat_history"];
            [subQuery1 whereKey:@"challenge" equalTo:[NSNull null]];
            PFQuery *subQuery2 = [PFQuery queryWithClassName:@"chat_history"];
            [subQuery2 whereKey:@"challenge" notEqualTo:[NSNull null]];
            [subQuery2 whereKey:@"challenge_solved" equalTo:@YES];
            PFQuery *queryUnshownMessages = [PFQuery orQueryWithSubqueries:@[subQuery1, subQuery2]];
            [queryUnshownMessages whereKey:@"from_user" equalTo:_selectedUser];
            [queryUnshownMessages whereKey:@"to_user" equalTo:[PFUser currentUser]];
            if (historyData.lastShownMessage != nil)
                [queryUnshownMessages whereKey:@"updatedAt" greaterThan:historyData.lastShownMessage.updatedAt];
            [queryUnshownMessages countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error != nil)
                    unshownMessageBadge.badgeText = @"";
                else
                    unshownMessageBadge.badgeText = [NSString stringWithFormat:@"%d", number];
            }];
        }
    }
    
    if (historyData.unsolvedChallengeCount <= 0)
        unsolvedChallengeBadge.badgeText = @"";
    else
        unsolvedChallengeBadge.badgeText = [NSString stringWithFormat:@"%ld", historyData.unsolvedChallengeCount];
    
    if (historyData.lastMessage == nil)
        _lblLastMessageTime.text = @"";
    else
        _lblLastMessageTime.text = [Globals stringOfTime:historyData.lastMessage.updatedAt];
    
    if (isInitial == YES || isOthersChanges == YES)
        return;
    
    NSArray *arrayFriendRelations = [Globals arrayFriendRelations];
    for (int i = 0; i < arrayFriendRelations.count; i ++)
    {
        if (i == relationIndex)
            continue;
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        HistoryData *historyData = [[Globals dictionaryHistoryData] objectForKey:friendRelation.relationId];
        if (historyData == nil)
            continue;
        
        if (historyData.lastMessage != nil)
        {
            if (historyData.lastShownMessage == nil)
            {
                isOthersChanges = YES;
                _btnBack.selected = isOthersChanges;
                break;
            }
            else if (![historyData.lastShownMessage.objectId isEqualToString:historyData.lastMessage.objectId])
            {
                isOthersChanges = YES;
                _btnBack.selected = isOthersChanges;
                break;
            }
        }
        if (historyData.lastChallenge != nil)
        {
            if (historyData.lastShownChallenge == nil)
            {
                isOthersChanges = YES;
                _btnBack.selected = isOthersChanges;
                break;
            }
            else if (![historyData.lastShownChallenge.objectId isEqualToString:historyData.lastChallenge.objectId])
            {
                isOthersChanges = YES;
                _btnBack.selected = isOthersChanges;
                break;
            }
        }
    }
}

- (void)removeAllSubViewsInView:(UIView *)view
{
    if (view == nil)
        return;
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
