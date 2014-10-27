//
//  SignupViewController.m
//  Chatlenge
//
//  Created by lion on 6/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Globals.h"
#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

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
    [_viewWaiting setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
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

- (IBAction)onStopInput:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
}

- (IBAction)onSignup:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
    
    NSString *strUsername = _txtUsername.text;
    NSString *strPassword = _txtPassword.text;
    
    if ([strUsername isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Error!" message:@"Please type in user name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return;
    }
    if ([strPassword isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Error!" message:@"Please type in password." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return;
    }
    
    [_viewWaiting setHidden:NO];
    
    PFUser *user = [PFUser user];
    user.username = strUsername;
    user.password = strPassword;
    user[@"username_l"] = [strUsername lowercaseString];
    user[@"acc_status"] = [NSNumber numberWithInt:ACCOUNT_ACTIVE];
    user[@"usr_type"] = [NSNumber numberWithInt:USER_TYPE_NORMAL];
    user[@"online_status"] = [NSNumber numberWithInt:(USER_ONLINE|USER_AVAILABLE)];
    user[@"scores"] = [NSNumber numberWithInt:0];
    user[@"credits"] = [NSNumber numberWithInt:5];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFUser *chatlengeUser = [PFUser objectWithoutDataWithObjectId:kDefaultChatlengeUserId];
            PFObject *friendRelationObject = [PFObject objectWithClassName:@"friends"];
            friendRelationObject[@"left_user"] = chatlengeUser;
            friendRelationObject[@"right_user"] = [PFUser currentUser];
            friendRelationObject[@"accepted"] = @YES;
            [friendRelationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFQuery *queryMessages = [PFQuery queryWithClassName:@"greeting_messages"];
                [queryMessages orderByAscending:@"createdAt"];
                [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error != nil ||
                        objects == nil ||
                        objects.count <= 0)
                    {
                        [_viewWaiting setHidden:YES];
                        [APP_DELEGATE gotoMainScreen];
                        return;
                    }
                    
                    __block int saveCount = 0;
                    for (int i = 0; i < objects.count; i ++)
                    {
                        PFObject *greetingObject = [objects objectAtIndex:i];
                        int msgType = [greetingObject[@"msg_type"] intValue];
                        
                        PFObject *messageObject = [PFObject objectWithClassName:@"chat_history"];
                        messageObject[@"from_user"] = chatlengeUser;
                        messageObject[@"to_user"] = [PFUser currentUser];
                        messageObject[@"msg_type"] = [NSNumber numberWithInt:msgType];
                        if (msgType == MEDIA_TEXT)
                            messageObject[@"msg_text"] = greetingObject[@"msg_text"];
                        else
                            messageObject[@"msg_image"] = greetingObject[@"msg_image"];
                        [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            saveCount ++;
                            NSLog(@"Saving greeting message %d", saveCount);
                            if (saveCount >= objects.count)
                            {
                                NSLog(@"All greeting messages saved.");
                                [_viewWaiting setHidden:YES];
                                [APP_DELEGATE gotoMainScreen];
                            }
                        }];
                    }
                }];
            }];
        } else {
            [_viewWaiting setHidden:YES];
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

- (IBAction)onBack:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)keyboardWillShow {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    rect.origin.y -= (kOFFSET_FOR_KEYBOARD - 120.f);
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillHide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    rect.origin.y += (kOFFSET_FOR_KEYBOARD - 120.f);
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtUsername)
        [_txtPassword becomeFirstResponder];
    else
        [self onSignup:nil];
    return YES;
}

@end
