//
//  ChallengeEditViewController.m
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"
#import "UIImage+Extension.h"
#import "ChallengeEditViewController.h"
#import "PickChallengeViewController.h"

@interface ChallengeEditViewController ()
{
    NSMutableArray *arrayMessages;
    NSDate *pickedTime;
    int currentScreen;
    
    BOOL isKeyboardShown;
    CGRect rcContainer;
}
@end

@implementation ChallengeEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrayMessages = [[NSMutableArray alloc] init];
        pickedTime = [NSDate date];
        
        isKeyboardShown = NO;
        rcContainer = CGRectZero;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isKeyboardShown = NO;
    rcContainer = CGRectZero;
    
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    PFUser *selectedUser = pickController.selectedUser;
    
    _lblUsername.text = [Globals displayNameForUser:selectedUser];
    
    if (_challengeType == QUEST_CHALLENGE)
    {
        _lblSlogan.text = @"Set your message and question...";
        _imgChallengeType.image = [UIImage imageNamed:@"q_challenge_in_mark.png"];
        _viewQuestionContainer.hidden = NO;
        _viewEvidenceContainer.hidden = YES;
        _viewDateContainer.hidden = YES;
        _datePicker.hidden = YES;
    }
    else if (_challengeType == EVID_CHALLENGE)
    {
        _lblSlogan.text = @"Set your messages...";
        _imgChallengeType.image = [UIImage imageNamed:@"e_challenge_in_mark.png"];
        _viewQuestionContainer.hidden = YES;
        _viewEvidenceContainer.hidden = NO;
        _viewDateContainer.hidden = YES;
        _datePicker.hidden = YES;
    }
    else if (_challengeType == DATE_CHALLENGE)
    {
        _lblSlogan.text = @"Set your message and opening date...";
        _imgChallengeType.image = [UIImage imageNamed:@"d_challenge_in_mark.png"];
        _viewQuestionContainer.hidden = YES;
        _viewEvidenceContainer.hidden = YES;
        _viewDateContainer.hidden = NO;
        _datePicker.hidden = YES;
        
        pickedTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [_btnDate setTitle:[dateFormatter stringFromDate:pickedTime] forState:UIControlStateNormal];
        _datePicker.date = pickedTime;
    }
    
    currentScreen = 0;
    _btnMessages.selected = YES;
    _btnContents.selected = NO;
    _viewMessagesContainer.hidden = NO;
    _viewContentsContainer.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
    [self resignAllFirstResponder];
    _datePicker.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMessages:(id)sender
{
    [self resignAllFirstResponder];
    _datePicker.hidden = YES;
    
    if (currentScreen == 0)
        return;
    currentScreen = 0;
    _btnMessages.selected = YES;
    _btnContents.selected = NO;
    _viewMessagesContainer.hidden = NO;
    _viewContentsContainer.hidden = YES;
}

- (IBAction)onContents:(id)sender
{
    [self resignAllFirstResponder];
    _datePicker.hidden = YES;
    
    if (currentScreen == 1)
        return;
    currentScreen = 1;
    _btnMessages.selected = NO;
    _btnContents.selected = YES;
    _viewMessagesContainer.hidden = YES;
    _viewContentsContainer.hidden = NO;
}

- (IBAction)onSendTextMessage:(id)sender
{
    _datePicker.hidden = YES;
    
    if ([_txtMessageToSend.text isEqualToString:@""])
         return;
    
    NSString *strMessage = _txtMessageToSend.text;
    _txtMessageToSend.text = @"";
    
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    
    PFObject *messageObject = [PFObject objectWithClassName:@"chat_history"];
    messageObject[@"from_user"] = [PFUser currentUser];
    messageObject[@"to_user"] = pickController.selectedUser;
    messageObject[@"msg_type"] = [NSNumber numberWithInt:MEDIA_TEXT];
    messageObject[@"msg_text"] = strMessage;
    
    [arrayMessages addObject:messageObject];
    [_tableMessages reloadData];
    [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

- (IBAction)onSendPhotoMessage:(id)sender
{
    [self resignAllFirstResponder];
    _datePicker.hidden = YES;
    
    PhotoPickerViewController *photoPickerController = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    photoPickerController.delegate = self;
    [self.navigationController pushViewController:photoPickerController animated:YES];
}

- (IBAction)onPickDate:(id)sender
{
    [self resignAllFirstResponder];
    if (_datePicker.hidden == NO)
        _datePicker.hidden = YES;
    else
        _datePicker.hidden = NO;
}

- (IBAction)onSetChallenge:(id)sender
{
    [self resignAllFirstResponder];
    _datePicker.hidden = YES;
    
    if ([self checkChallengeValues] == NO)
        return;
    
    ChallengeData *challengeData = [self buildChallengeData];
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    if (pickController.delegate != nil &&
        [pickController.delegate respondsToSelector:@selector(didFinishPickingChallenge:)])
        [pickController.delegate didFinishPickingChallenge:challengeData];

}

- (IBAction)onDateChanged:(id)sender
{
    pickedTime = _datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [_btnDate setTitle:[dateFormatter stringFromDate:pickedTime] forState:UIControlStateNormal];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageTableViewCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageTableViewCell"];
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    PFObject *messageObject = [arrayMessages objectAtIndex:indexPath.row];
    CGSize contentSize = [self contentSizeForRowAtIndexPath:indexPath];
    
    CGRect rcFrame = CGRectMake(310 - (contentSize.width + 30.f), 10, contentSize.width + 30.f, contentSize.height + 14.f);
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:rcFrame];
    bubbleImageView.image = [[UIImage imageNamed:@"bubble-outgoing.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 16, 20, 26)];
    
    [cell.contentView addSubview:bubbleImageView];
    
    if ([messageObject[@"msg_type"] intValue] == MEDIA_TEXT)
    {
        UILabel *labelMessage = [[UILabel alloc] init];
        labelMessage.font = [UIFont systemFontOfSize:14.f];
        labelMessage.text = messageObject[@"msg_text"];
        labelMessage.numberOfLines = 0;
        rcFrame = CGRectMake(310 - (contentSize.width + 20.f), 16, contentSize.width, contentSize.height);
        labelMessage.frame = rcFrame;
        
        [cell.contentView addSubview:labelMessage];
    }
    else if ([messageObject[@"msg_type"] intValue] == MEDIA_PHOTO)
    {
        rcFrame = CGRectMake(310 - (contentSize.width + 20.f), 16, contentSize.width, contentSize.height);
        PFFile *photoFile = messageObject[@"msg_image"];
        if (photoFile.isDataAvailable)
        {
            UIImageView *photoImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[photoFile getData]]];
            photoImageView.frame = rcFrame;
            photoImageView.layer.masksToBounds = YES;
            photoImageView.layer.cornerRadius = 5.f;
            
            [cell.contentView addSubview:photoImageView];
        }
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
    return (contentSize.height + 20.f + 14.f);
}

- (CGSize)contentSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *messageObject = [arrayMessages objectAtIndex:indexPath.row];
    
    int msgType = [messageObject[@"msg_type"] intValue];
    if (msgType == MEDIA_TEXT)
    {
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.font = [UIFont systemFontOfSize:14.f];
        tempLabel.text = messageObject[@"msg_text"];
        tempLabel.numberOfLines = 0;
        CGRect rcBounds = [tempLabel textRectForBounds:CGRectMake(0, 0, 240.f, 9999.f) limitedToNumberOfLines:0];
        tempLabel = nil;
        
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
            if (width > 240.f)
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
    [self resignAllFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtMessageToSend)
    {
        if ([_txtMessageToSend.text isEqualToString:@""])
        {
            [textField resignFirstResponder];
            return YES;
        }
        
        [self onSendTextMessage:nil];
        return YES;
    }
    
    [textField resignFirstResponder];
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    if (currentScreen == 0)
    {
        if (rcContainer.size.width == 0 ||
            rcContainer.size.height == 0)
            rcContainer = _viewMessagesContainer.frame;
        
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        CGRect rect = CGRectMake(rcContainer.origin.x, rcContainer.origin.y, rcContainer.size.width, rcContainer.size.height - kbSize.height);
        _viewMessagesContainer.frame = rect;
        
        [UIView commitAnimations];
        
        if (arrayMessages != nil &&
            arrayMessages.count > 0)
            [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        CGRect rect = self.view.frame;
        rect.origin.y = -(kOFFSET_FOR_KEYBOARD - 80.f);
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
    
    if (currentScreen == 0)
    {
        _btnContents.enabled = NO;
        _btnMessages.enabled = YES;
    }
    else
    {
        _btnContents.enabled = YES;
        _btnMessages.enabled = NO;
    }
    
    isKeyboardShown = YES;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    if (isKeyboardShown && currentScreen == 0)
    {
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        CGRect rect = CGRectMake(rcContainer.origin.x, rcContainer.origin.y, rcContainer.size.width, rcContainer.size.height - kbSize.height);
        _viewMessagesContainer.frame = rect;
        
        [UIView commitAnimations];
        
        if (arrayMessages != nil &&
            arrayMessages.count > 0)
            [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    if (currentScreen == 0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        _viewMessagesContainer.frame = rcContainer;
        
        [UIView commitAnimations];
        
        if (arrayMessages != nil &&
            arrayMessages.count > 0)
            [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
        
        [UIView commitAnimations];
    }
    
    _btnContents.enabled = YES;
    _btnMessages.enabled = YES;
    
    isKeyboardShown = NO;
}

- (void)photoPickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController popToViewController:self animated:NO];

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"Current size : %@", NSStringFromCGSize(image.size));
    CGSize newSize = image.size;
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
    UIImage *scaledPhoto = [[image fixOrientation] scaleToSize:newSize];
    NSLog(@"Resized : %@", NSStringFromCGSize(scaledPhoto.size));
    
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    
    PFObject *messageObject = [PFObject objectWithClassName:@"chat_history"];
    messageObject[@"from_user"] = [PFUser currentUser];
    messageObject[@"to_user"] = pickController.selectedUser;
    messageObject[@"msg_type"] = [NSNumber numberWithInt:MEDIA_PHOTO];
    messageObject[@"msg_image"] = [PFFile fileWithData:UIImageJPEGRepresentation(scaledPhoto, .5f)];
    
    [arrayMessages addObject:messageObject];
    [_tableMessages reloadData];
    [_tableMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)photoPickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [self.navigationController popToViewController:self animated:NO];
}

- (void)resignAllFirstResponder
{
    if ([_txtMessageToSend isFirstResponder])
        [_txtMessageToSend resignFirstResponder];
    else
        [self.view endEditing:YES];
}

- (BOOL)checkChallengeValues
{
    if (arrayMessages.count <= 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please input your message." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alertView show];
        return NO;
    }
    
    if (_challengeType == QUEST_CHALLENGE)
    {
        if ([_txtQuestion.text isEqualToString:@""])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please input your question." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return NO;
        }
        if ([_txtAnswer.text isEqualToString:@""])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please input your expected answer." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return NO;
        }
    }
    else if (_challengeType == EVID_CHALLENGE)
    {
        if ([_txtEvidence.text isEqualToString:@""])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please input your challenge message." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return NO;
        }
    }
    else if (_challengeType == DATE_CHALLENGE)
    {
        if ([pickedTime compare:[NSDate date]] != NSOrderedDescending)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please pick valid date." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return NO;
        }
    }
    
    return YES;
}

- (ChallengeData *)buildChallengeData
{
    ChallengeData *challengeData = [[ChallengeData alloc] init];
    challengeData.arrayMessages = arrayMessages;
    
    PickChallengeViewController *pickController = (PickChallengeViewController *)self.navigationController;
    
    PFObject *challengeObject = [PFObject objectWithClassName:@"challenge_history"];
    challengeObject[@"from_user"] = [PFUser currentUser];
    challengeObject[@"to_user"] = pickController.selectedUser;
    challengeObject[@"challenge_type"] = [NSNumber numberWithInt:_challengeType];
    challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SUGGESTED];
    challengeObject[@"force_solved"] = @NO;
    challengeObject[@"from_scored"] = @NO;
    challengeObject[@"to_scored"] = @NO;
    
    if (_challengeType == QUEST_CHALLENGE)
    {
        challengeObject[@"suggest_type"] = [NSNumber numberWithInt:MEDIA_TEXT];
        challengeObject[@"suggest_text"] = _txtQuestion.text;
        challengeObject[@"answer_type"] = [NSNumber numberWithInt:MEDIA_TEXT];
        challengeObject[@"answer_text"] = _txtAnswer.text;
    }
    else if (_challengeType == EVID_CHALLENGE)
    {
        challengeObject[@"suggest_type"] = [NSNumber numberWithInt:MEDIA_TEXT];
        challengeObject[@"suggest_text"] = _txtEvidence.text;
    }
    else if (_challengeType == DATE_CHALLENGE)
    {
        challengeObject[@"suggest_type"] = [NSNumber numberWithInt:MEDIA_TIME];
        challengeObject[@"suggest_time"] = pickedTime;
    }
    
    challengeData.challengeObject = challengeObject;
    
    return challengeData;
}

@end
