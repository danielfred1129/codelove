//
//  LoginViewController.h
//  Chatlenge
//
//  Created by lion on 6/11/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIView *viewWaiting;

- (IBAction)onLogin:(id)sender;
- (IBAction)onReset:(id)sender;
- (IBAction)onSignup:(id)sender;
- (IBAction)onStopInput:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
