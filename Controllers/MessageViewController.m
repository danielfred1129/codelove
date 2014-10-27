//
//  MessageViewController.m
//  Chatlenge
//
//  Created by lion on 7/15/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"
#import "AppDelegate.h"
#import "FriendRelation.h"
#import "HistoryData.h"
#import "UIImage+Extension.h"
#import "ChallengeInfoPluginView.h"
#import "MessageViewController.h"

@interface MessageViewController ()
{
    BOOL isKeyboardShown;
    CGRect rcContainer;
}
@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrayMessages = nil;
        _isShown = NO;
        
        isKeyboardShown = NO;
        rcContainer = CGRectZero;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive:) name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:kNotification_Message_Received object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChallengeChanged:) name:kNotification_Challenge_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLinkMessage:) name:kNotification_Link_Message object:nil];
    
    isKeyboardShown = NO;
    rcContainer = CGRectZero;
    
    _isShown = NO;
    [self refreshAllMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Message_Received object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Challenge_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Link_Message object:nil];
}

// TableView delegate implementations
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayMessages == nil)
        return 0;
    else
        return arrayMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arrayMessages == nil)
        return nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageTableViewCell"];
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    PFObject *messageObject = [arrayMessages objectAtIndex:(arrayMessages.count - 1 - indexPath.row)];
    CGSize contentSize = [self contentSizeForRowAtIndexPath:indexPath];
    PFUser *leftUser = messageObject[@"from_user"];
    
    CGRect rcFrame;
    if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
    {
        if (messageObject[@"challenge"] == nil)
            rcFrame = CGRectMake(310 - (contentSize.width + 30.f), 10, contentSize.width + 30.f, contentSize.height + 14.f);
        else
            rcFrame = CGRectMake(310 - (240.f + 30.f), 10, 240.f + 30.f, contentSize.height + 14.f + 35.f);
    }
    else
    {
        if (messageObject[@"challenge"] == nil)
            rcFrame = CGRectMake(10, 10, contentSize.width + 30.f, contentSize.height + 14.f);
        else
            rcFrame = CGRectMake(10, 10, 240.f + 30.f, contentSize.height + 14.f + 35.f);
    }
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:rcFrame];
    if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
        bubbleImageView.image = [[UIImage imageNamed:@"bubble-outgoing.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 16, 20, 26)];
    else
        bubbleImageView.image = [[UIImage imageNamed:@"bubble-incoming.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 26, 20, 16)];
    
    [cell.contentView addSubview:bubbleImageView];
    
    if ([messageObject[@"msg_type"] intValue] == MEDIA_TEXT)
    {
        UILabel *labelMessage = [[UILabel alloc] init];
        labelMessage.font = [UIFont systemFontOfSize:14.f];
        labelMessage.text = messageObject[@"msg_text"];
        labelMessage.numberOfLines = 0;
        if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
            rcFrame = CGRectMake(310 - (contentSize.width + 20.f), 16, contentSize.width, contentSize.height);
        else
            rcFrame = CGRectMake(28, 16, contentSize.width, contentSize.height);
        labelMessage.frame = rcFrame;
        
        [cell.contentView addSubview:labelMessage];
    }
    else if ([messageObject[@"msg_type"] intValue] == MEDIA_PHOTO)
    {
        if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
            rcFrame = CGRectMake(310 - (contentSize.width + 20.f), 16, contentSize.width, contentSize.height);
        else
            rcFrame = CGRectMake(28, 16, contentSize.width, contentSize.height);
        
        PFFile *photoFile = messageObject[@"msg_image"];
        if (photoFile.isDataAvailable)
        {
            UIImageView *photoImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[photoFile getData]]];
            photoImageView.frame = rcFrame;
            photoImageView.layer.masksToBounds = YES;
            photoImageView.layer.cornerRadius = 5.f;
            
            [cell.contentView addSubview:photoImageView];
        }
        else
        {
            [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [_tableMessages reloadData];
//                [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }];
        }
    }
    
/*    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(20, contentSize.height + 20.f + 14.f, 280, 20)];
    if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
        labelTime.textAlignment = NSTextAlignmentRight;
    else
        labelTime.textAlignment = NSTextAlignmentLeft;
    labelTime.font = [UIFont systemFontOfSize:13.f];
    labelTime.textColor = [UIColor darkGrayColor];
    NSDate *messageTime = messageObject.updatedAt;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    labelTime.text = [dateFormatter stringFromDate:messageTime];
    
    [cell.contentView addSubview:labelTime];*/
    
    PFObject *challengeObject = messageObject[@"challenge"];
    if (challengeObject != nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeInfoPluginView" owner:self options:nil];
        ChallengeInfoPluginView *challengePlugin = [topLevelObjects objectAtIndex:0];
        rcFrame = CGRectMake(rcFrame.origin.x, rcFrame.origin.y + rcFrame.size.height + 10.f, 240.f, 25.f);
        challengePlugin.frame = rcFrame;
        
        int challengeType = [challengeObject[@"challenge_type"] intValue];
        if (challengeType == QUEST_CHALLENGE)
        {
            if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"q_challenge_out_mark.png"];
            else
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"q_challenge_in_mark.png"];
        }
        else if (challengeType == EVID_CHALLENGE)
        {
            if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"e_challenge_out_mark.png"];
            else
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"e_challenge_in_mark.png"];
        }
        else if (challengeType == DATE_CHALLENGE)
        {
            if ([leftUser.objectId isEqualToString:[PFUser currentUser].objectId])
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"d_challenge_out_mark.png"];
            else
                challengePlugin.imgChallengeType.image = [UIImage imageNamed:@"d_challenge_in_mark.png"];
        }
        else
            challengePlugin.imgChallengeType.image = nil;
        
        int suggestType = [challengeObject[@"suggest_type"] intValue];
        if (suggestType == MEDIA_TEXT)
            challengePlugin.lblChallengeTitle.text = challengeObject[@"suggest_text"];
        else if (suggestType == MEDIA_PHOTO)
            challengePlugin.lblChallengeTitle.text = @"...";
        else if (suggestType == MEDIA_TIME)
        {
            NSDate *date = challengeObject[@"suggest_time"];
            if (date == nil)
                challengePlugin.lblChallengeTitle.text = nil;
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                challengePlugin.lblChallengeTitle.text = [dateFormatter stringFromDate:date];
            }
        }
        
        int challengePhase = [challengeObject[@"phase"] intValue];
        if (challengePhase == CHALLENGE_SUGGESTED)
            challengePlugin.imgChallengePhase.image = [UIImage imageNamed:@"busy_mark.png"];
        else if (challengePhase == CHALLENGE_ANSWERED)
            challengePlugin.imgChallengePhase.image = [UIImage imageNamed:@"away_mark.png"];
        else if (challengePhase == CHALLENGE_SOLVED)
            challengePlugin.imgChallengePhase.image = [UIImage imageNamed:@"online_mark.png"];
        else
            challengePlugin.imgChallengePhase.image = nil;
        
        challengePlugin.btnGotoChallenge.tag = indexPath.row;
        [challengePlugin.btnGotoChallenge addTarget:self action:@selector(onLinkChallenge:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:challengePlugin];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize contentSize = [self contentSizeForRowAtIndexPath:indexPath];
    
    PFObject *messageObject = [arrayMessages objectAtIndex:(arrayMessages.count - 1 - indexPath.row)];
    PFObject *challengeObject = messageObject[@"challenge"];
    if (challengeObject == nil)
        return (contentSize.height + 20.f + 14.f/* + 20.f*/);
    return (contentSize.height + 20.f + 14.f/* + 20.f*/ + 35.f);
}

- (CGSize)contentSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arrayMessages == nil)
        return CGSizeZero;
    
    PFObject *messageObject = [arrayMessages objectAtIndex:(arrayMessages.count - 1 - indexPath.row)];
    PFObject *challengeObject = messageObject[@"challenge"];
    
    int msgType = [messageObject[@"msg_type"] intValue];
    if (msgType == MEDIA_TEXT)
    {
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.font = [UIFont systemFontOfSize:14.f];
        tempLabel.text = messageObject[@"msg_text"];
        tempLabel.numberOfLines = 0;
        CGRect rcBounds = [tempLabel textRectForBounds:CGRectMake(0, 0, 240.f, 9999.f) limitedToNumberOfLines:0];
        tempLabel = nil;
        
        if (challengeObject != nil)
            return CGSizeMake(240.f, rcBounds.size.height);
        return rcBounds.size;
    }
    else if (msgType == MEDIA_PHOTO)
    {
        PFFile *photoFile = messageObject[@"msg_image"];
        if (photoFile.isDataAvailable)
        {
            UIImage *photoImage = [UIImage imageWithData:[photoFile getData]];
            CGFloat width = photoImage.size.width / 2;
            CGFloat height = photoImage.size.height / 2;
            if (challengeObject != nil ||
                width > 240.f)
            {
                CGFloat scale = 240.f / width;
                width = 240.f;
                height = height * scale;
                return CGSizeMake(width, height);
            }
            return CGSizeMake(width, height);
        }
        else
        {
            if (challengeObject != nil)
                return CGSizeMake(240.f, 20.f);
            return CGSizeMake(20.f, 20.f);
        }
    }
    else
    {
        return CGSizeZero;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_txtMessage resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (rcContainer.size.width == 0 ||
        rcContainer.size.height == 0)
        rcContainer = _viewContainer.frame;
    
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = CGRectMake(rcContainer.origin.x, rcContainer.origin.y, rcContainer.size.width, rcContainer.size.height - kbSize.height);
    _viewContainer.frame = rect;
    
    [UIView commitAnimations];
    
    if (arrayMessages != nil &&
        arrayMessages.count > 0)
        [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    isKeyboardShown = YES;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if (isKeyboardShown)
    {
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        CGRect rect = CGRectMake(rcContainer.origin.x, rcContainer.origin.y, rcContainer.size.width, rcContainer.size.height - kbSize.height);
        _viewContainer.frame = rect;
        
        [UIView commitAnimations];
        
        if (arrayMessages != nil &&
            arrayMessages.count > 0)
            [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    _viewContainer.frame = rcContainer;
    
    [UIView commitAnimations];
    
    if (arrayMessages != nil &&
        arrayMessages.count > 0)
        [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    isKeyboardShown = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""])
    {
        [textField resignFirstResponder];
        return NO;
    }
    
    [self onSendMessage:nil];
    return NO;
}

- (IBAction)onSendMessage:(id)sender
{
    NSString *strMessage = _txtMessage.text;
    _txtMessage.text = @"";
    [self sendTextMessage:strMessage];
}

- (IBAction)onSendPhoto:(id)sender
{
    [_txtMessage resignFirstResponder];
    
    PhotoPickerViewController *photoPickerController = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    photoPickerController.delegate = self;
    [_superViewController presentViewController:photoPickerController animated:YES completion:nil];
}

- (void)sendTextMessage:(NSString *)message
{
    if (message == nil ||
        [message isEqualToString:@""])
        return;
    
    PFObject *messageObject = [PFObject objectWithClassName:@"chat_history"];
    messageObject[@"from_user"] = [PFUser currentUser];
    messageObject[@"to_user"] = _selectedUser;
    messageObject[@"msg_type"] = [NSNumber numberWithInt:MEDIA_TEXT];
    messageObject[@"msg_text"] = message;
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded == NO ||
            error != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Message" message:@"Failed to send message." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            return;
        }
        
        NSString *messageToSend = [NSString stringWithFormat:@"%@: \"%@\"", [Globals displayNameForUser:[PFUser currentUser]], message];
        [AppDelegate sendPushMessageToUser:_selectedUser withMessage:messageToSend withType:NOTIFY_INSTANT_MESSAGE withCustomData:@{@"message_id":messageObject.objectId}];
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:arrayMessages];
        [newArray insertObject:messageObject atIndex:0];
        arrayMessages = newArray;
        [_tableMessages reloadData];
        [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

- (void)sendPhotoMessage:(UIImage *)photo
{
    if (photo == nil)
        return;
    
    NSLog(@"Current size : %@", NSStringFromCGSize(photo.size));
    CGSize newSize = photo.size;
    if (newSize.width > kRESTRICT_PHOTO_SIZE)
    {
        CGFloat scale = kRESTRICT_PHOTO_SIZE / newSize.width;
        newSize.width = kRESTRICT_PHOTO_SIZE;
        newSize.height = newSize.height * scale;
    }
    /*if (newSize.height > kRESTRICT_PHOTO_SIZE)
    {
        CGFloat scale = kRESTRICT_PHOTO_SIZE / newSize.height;
        newSize.height = kRESTRICT_PHOTO_SIZE;
        newSize.width = newSize.width * scale;
    }*/
    NSLog(@"Resizing : %@", NSStringFromCGSize(newSize));
    UIImage *scaledPhoto = [[photo fixOrientation] scaleToSize:newSize];
    NSLog(@"Resized : %@", NSStringFromCGSize(scaledPhoto.size));
    
    PFObject *messageObject = [PFObject objectWithClassName:@"chat_history"];
    messageObject[@"from_user"] = [PFUser currentUser];
    messageObject[@"to_user"] = _selectedUser;
    messageObject[@"msg_type"] = [NSNumber numberWithInt:MEDIA_PHOTO];
    messageObject[@"msg_image"] = [PFFile fileWithData:UIImageJPEGRepresentation(scaledPhoto, .5f)];
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded == NO ||
            error != nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Message" message:@"Failed to send message." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            return;
        }
        
        NSString *messageToSend = [NSString stringWithFormat:@"%@ sent you a photo.", [Globals displayNameForUser:[PFUser currentUser]]];
        [AppDelegate sendPushMessageToUser:_selectedUser withMessage:messageToSend withType:NOTIFY_INSTANT_MESSAGE withCustomData:@{@"message_id":messageObject.objectId}];
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:arrayMessages];
        [newArray insertObject:messageObject atIndex:0];
        arrayMessages = newArray;
        [_tableMessages reloadData];
        [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

- (void)onMessageReceived:(NSNotification *)notification
{
    NSDictionary *dictData = notification.userInfo;
    NSString *fromUserId = [dictData objectForKey:@"from_user"];
    int type = [[dictData objectForKey:@"type"] intValue];
    if (type != NOTIFY_INSTANT_MESSAGE)
        return;
    if (![fromUserId isEqualToString:_selectedUser.objectId])
        return;
    
    NSString *messageId = [dictData objectForKey:@"message_id"];
    PFObject *messageObject = [PFObject objectWithoutDataWithClassName:@"chat_history" objectId:messageId];
    [messageObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error != nil ||
            object == nil)
            return;
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:arrayMessages];
        [newArray insertObject:object atIndex:0];
        arrayMessages = newArray;
        [_tableMessages reloadData];
        [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        if (_isShown)
            [self updateLastShownMessage];
    }];
}

- (void)onChallengeChanged:(NSNotification *)notification
{
    [self refreshAllMessages];
}

- (void)onAppBecomeActive:(NSNotification *)notification
{
    [self refreshAllMessages];
}

- (void)onLinkMessage:(NSNotification *)notification
{
    if (arrayMessages == nil)
        return;
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *challengeId = [userInfo objectForKey:@"challenge_id"];
    int messageIndex = -1;
    for (int i = 0; i < arrayMessages.count; i ++)
    {
        PFObject *messageObject = [arrayMessages objectAtIndex:i];
        PFObject *challengeObject = messageObject[@"challenge"];
        if (challengeObject == nil)
            continue;
        if ([challengeObject.objectId isEqualToString:challengeId])
        {
            messageIndex = i;
            break;
        }
    }
    if (messageIndex == -1)
        return;
    
    [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1 - messageIndex) inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)onLinkChallenge:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger arrayIndex = button.tag;
    PFObject *messageObject = [arrayMessages objectAtIndex:(arrayMessages.count - 1 - arrayIndex)];
    PFObject *challengeObject = messageObject[@"challenge"];
    if (challengeObject == nil)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Link_Challenge object:nil userInfo:@{@"challenge_id":challengeObject.objectId}];
}

- (void)photoPickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_superViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        [self sendPhotoMessage:image];
    }];
}

- (void)photoPickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [_superViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)refreshAllMessages
{
    PFQuery *queryMessages1 = [PFQuery queryWithClassName:@"chat_history"];
    [queryMessages1 whereKey:@"from_user" equalTo:_selectedUser];
    [queryMessages1 whereKey:@"to_user" equalTo:[PFUser currentUser]];
    PFQuery *queryMessages2 = [PFQuery queryWithClassName:@"chat_history"];
    [queryMessages2 whereKey:@"from_user" equalTo:[PFUser currentUser]];
    [queryMessages2 whereKey:@"to_user" equalTo:_selectedUser];
    
    PFQuery *queryMessages = [PFQuery orQueryWithSubqueries:@[queryMessages1, queryMessages2]];
    [queryMessages orderByDescending:@"updatedAt"];
    [queryMessages includeKey:@"from_user"];
    [queryMessages includeKey:@"to_user"];
    [queryMessages includeKey:@"challenge"];
    [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil ||
            objects == nil)
            return;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < objects.count; i ++)
        {
            PFObject *messageObject = [objects objectAtIndex:i];
            PFObject *challengeObject = messageObject[@"challenge"];
            if (challengeObject == nil)
            {
                [array addObject:messageObject];
                continue;
            }
            PFUser *fromUser = messageObject[@"from_user"];
            if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
            {
                [array addObject:messageObject];
                continue;
            }
            BOOL isSolved = [messageObject[@"challenge_solved"] boolValue];
            if (isSolved)
            {
                [array addObject:messageObject];
                continue;
            }
        }
        arrayMessages = array;
        [_tableMessages reloadData];
        if (arrayMessages.count > 0)
            [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        if (_isShown)
            [self updateLastShownMessage];
    }];
}

- (void)setIsShown:(BOOL)isShown
{
    _isShown = isShown;
    if (isShown)
        [self updateLastShownMessage];
}

- (void)updateLastShownMessage
{
    if (arrayMessages == nil ||
        arrayMessages.count <= 0)
        return;
    
    PFObject *lastMessageObject = nil;
    for (int i = 0; i < arrayMessages.count; i ++)
    {
        PFObject *messageObject = [arrayMessages objectAtIndex:i];
        PFUser *toUser = messageObject[@"to_user"];
        if ([toUser.objectId isEqualToString:[PFUser currentUser].objectId])
        {
            lastMessageObject = messageObject;
            break;
        }
    }
    if (lastMessageObject == nil)
        return;
    
    PFQuery *queryShownChat = [PFQuery queryWithClassName:@"shown_chats"];
    [queryShownChat whereKey:@"from_user" equalTo:_selectedUser];
    [queryShownChat whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryShownChat findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *shownChatObject;
        if (error != nil ||
            objects == nil ||
            objects.count <= 0)
        {
            shownChatObject = [PFObject objectWithClassName:@"shown_chats"];
            shownChatObject[@"from_user"] = _selectedUser;
            shownChatObject[@"to_user"] = [PFUser currentUser];
            shownChatObject[@"shown_chat"] = lastMessageObject;
        }
        else
        {
            shownChatObject = [objects objectAtIndex:0];
            shownChatObject[@"shown_chat"] = lastMessageObject;
        }
        [shownChatObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSInteger relationIndex = [self findIndexOfUserInFriendRelationList:_selectedUser.objectId];
                if (relationIndex == -1)
                    return;
                FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
                NSString *relationId = friendRelation.relationId;
                
                NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
                HistoryData *historyData = [dictionaryHistoryData objectForKey:relationId];
                if (historyData == nil)
                    historyData = [[HistoryData alloc] init];
                historyData.lastShownMessage = lastMessageObject;
                [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_History_Changed object:nil];
            }
        }];
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
