//
//  LoginViewController.m
//  Chatlenge
//
//  Created by lion on 6/11/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Globals.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "ResetViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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

- (IBAction)onLogin:(id)sender
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
    [PFUser logInWithUsernameInBackground:strUsername password:strPassword
                                    block:^(PFUser *user, NSError *error) {
                                        [_viewWaiting setHidden:YES];
                                        if (user) {
                                            PFUser *user = [PFUser currentUser];
                                            int online_status = [user[@"online_status"] intValue];
                                            user[@"online_status"] = [NSNumber numberWithInt:(online_status | USER_ONLINE)];
                                            [user saveInBackground];
                                            
                                            [APP_DELEGATE gotoMainScreen];
                                        } else {
                                            NSString *errorString = [error userInfo][@"error"];
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                            [alertView show];
                                        }
                                    }];
}

- (IBAction)onReset:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
    
    ResetViewController *resetController = [[ResetViewController alloc] initWithNibName:@"ResetViewController" bundle:nil];
    [self.navigationController pushViewController:resetController animated:YES];
}

- (IBAction)onSignup:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
    
    SignupViewController *signupController = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    [self.navigationController pushViewController:signupController animated:YES];
}

- (IBAction)onStopInput:(id)sender
{
    [_txtUsername resignFirstResponder];
    [_txtPassword resignFirstResponder];
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
        [self onLogin:nil];
    return YES;
}

@end
