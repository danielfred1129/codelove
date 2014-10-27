//
//  ChallengeEditViewController.h
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerViewController.h"

@interface ChallengeEditViewController : UIViewController <UITextFieldDelegate,
                                                           UITableViewDataSource,
                                                           UITableViewDelegate,
                                                           PhotoPickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblSlogan;
@property (strong, nonatomic) IBOutlet UIImageView *imgChallengeType;
@property (strong, nonatomic) IBOutlet UIButton *btnMessages;
@property (strong, nonatomic) IBOutlet UIButton *btnContents;
@property (strong, nonatomic) IBOutlet UIView *viewMessagesContainer;
@property (strong, nonatomic) IBOutlet UITableView *tableMessages;
@property (strong, nonatomic) IBOutlet UITextField *txtMessageToSend;
@property (strong, nonatomic) IBOutlet UIView *viewContentsContainer;
@property (strong, nonatomic) IBOutlet UIView *viewQuestionContainer;
@property (strong, nonatomic) IBOutlet UITextField *txtQuestion;
@property (strong, nonatomic) IBOutlet UITextField *txtAnswer;
@property (strong, nonatomic) IBOutlet UIView *viewEvidenceContainer;
@property (strong, nonatomic) IBOutlet UITextField *txtEvidence;
@property (strong, nonatomic) IBOutlet UIView *viewDateContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (assign, nonatomic) int challengeType;

- (IBAction)onBack:(id)sender;
- (IBAction)onMessages:(id)sender;
- (IBAction)onContents:(id)sender;
- (IBAction)onSendTextMessage:(id)sender;
- (IBAction)onSendPhotoMessage:(id)sender;
- (IBAction)onPickDate:(id)sender;
- (IBAction)onSetChallenge:(id)sender;
- (IBAction)onDateChanged:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
