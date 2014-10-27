//
//  SignupViewController.h
//  Chatlenge
//
//  Created by lion on 6/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIView *viewWaiting;

- (IBAction)onStopInput:(id)sender;
- (IBAction)onSignup:(id)sender;
- (IBAction)onBack:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
