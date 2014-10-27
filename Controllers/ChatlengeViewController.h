//
//  ChatlengeViewController.h
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MessageViewController.h"
#import "ChallengeViewController.h"
#import "CustomBadge.h"

@interface ChatlengeViewController : UIViewController
{
    int currentScreen;
    
    MessageViewController *messageViewController;
    ChallengeViewController *challengeViewController;
    
    CustomBadge *unshownMessageBadge;
    CustomBadge *unsolvedChallengeBadge;
    BOOL isOthersChanges;
}

@property (nonatomic, strong) PFUser *selectedUser;

@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblLastMessageTime;
@property (strong, nonatomic) IBOutlet UIView *viewUnshownMsgContainer;
@property (strong, nonatomic) IBOutlet UIView *viewUnsolvedChlContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblUnlockCount;
@property (strong, nonatomic) IBOutlet UIButton *btnMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnChallenge;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPhoto;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;

- (IBAction)onBack:(id)sender;
- (IBAction)onMessage:(id)sender;
- (IBAction)onChallenge:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
