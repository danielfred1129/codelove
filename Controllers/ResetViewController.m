//
//  ResetViewController.m
//  Chatlenge
//
//  Created by lion on 6/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Globals.h"
#import "ResetViewController.h"

@interface ResetViewController ()

@end

@implementation ResetViewController

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

- (IBAction)onReset:(id)sender
{
    [_txtEmail resignFirstResponder];
    
    [_viewWaiting setHidden:NO];
    [PFUser requestPasswordResetForEmailInBackground:_txtEmail.text block:^(BOOL succeeded, NSError *error) {
        [_viewWaiting setHidden:YES];
        if (succeeded)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset requested" message:@"Reset requested. You will receive reset mail soon." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alertView.tag = 1;
            [alertView show];
        }
        else
        {
            NSString *errorString = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset failed" message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

- (IBAction)onBack:(id)sender
{
    [_txtEmail resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onStopInput:(id)sender
{
    [_txtEmail resignFirstResponder];
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
    if (textField == _txtEmail)
        [self onReset:nil];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
