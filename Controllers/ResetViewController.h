//
//  ResetViewController.h
//  Chatlenge
//
//  Created by lion on 6/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UIView *viewWaiting;

- (IBAction)onReset:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onStopInput:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
