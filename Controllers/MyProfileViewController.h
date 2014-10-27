//
//  MyProfileViewController.h
//  Chatlenge
//
//  Created by lion on 6/17/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "PhotoPickerViewController.h"

@interface MyProfileViewController : UIViewController <UITextFieldDelegate,
                                                       PhotoPickerControllerDelegate,
                                                       SKProductsRequestDelegate,
                                                       SKPaymentTransactionObserver>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoto;
@property (strong, nonatomic) IBOutlet UITextField *txtFullName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblScores;
@property (strong, nonatomic) IBOutlet UILabel *lblCredits;
@property (strong, nonatomic) IBOutlet UIButton *btnPurchase;
@property (strong, nonatomic) IBOutlet UIView *viewWaiting;
@property (strong, nonatomic) IBOutlet UIButton *btnOnline;
@property (strong, nonatomic) IBOutlet UIButton *btnBusy;
@property (strong, nonatomic) IBOutlet UIButton *btnAway;
@property (strong, nonatomic) IBOutlet UIButton *btnMale;
@property (strong, nonatomic) IBOutlet UIButton *btnFemale;

- (IBAction)onStopInput:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)onSelectPhoto:(id)sender;
- (IBAction)onAddCredits:(id)sender;
- (IBAction)onStatusOnline:(id)sender;
- (IBAction)onStatusBusy:(id)sender;
- (IBAction)onStatusAway:(id)sender;
- (IBAction)onGenderMale:(id)sender;
- (IBAction)onGenderFemale:(id)sender;
- (IBAction)onLogout:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
