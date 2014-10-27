//
//  UserProfileViewController.h
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UserProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *selectedUser;

@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserphoto;
@property (strong, nonatomic) IBOutlet UILabel *lblUserscore;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserstatus;
@property (strong, nonatomic) IBOutlet UILabel *lblUserstatus;
@property (strong, nonatomic) IBOutlet UILabel *lblUserFullname;
@property (strong, nonatomic) IBOutlet UIView *viewSendContact;
@property (strong, nonatomic) IBOutlet UIView *viewResendCancel;
@property (strong, nonatomic) IBOutlet UIView *viewAcceptReject;
@property (strong, nonatomic) IBOutlet UIView *viewMessageRemove;

- (IBAction)onBack:(id)sender;
- (IBAction)onSendContact:(id)sender;
- (IBAction)onResendContact:(id)sender;
- (IBAction)onCancelRequest:(id)sender;
- (IBAction)onAcceptRequest:(id)sender;
- (IBAction)onRejectRequest:(id)sender;
- (IBAction)onMessageTo:(id)sender;
- (IBAction)onRemoveContact:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
