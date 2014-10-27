//
//  MyProfileViewController.m
//  Chatlenge
//
//  Created by lion on 6/17/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Globals.h"
#import "MyProfileViewController.h"
#import "HFImageEditorViewController.h"

#define kBuyCreditsProductId        @"com.ballofpaper.chatlenge.buycredits"

@interface MyProfileViewController ()
{
    int onlineStatusIndex;
    int genderIndex;
    
    SKProduct *validProduct;
}
@end

@implementation MyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        validProduct = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCreditsChanged:) name:kNotification_Credits_Changed object:nil];

    _btnPhoto.layer.masksToBounds = YES;
    _btnPhoto.layer.cornerRadius = 50.f;
    
    _scrollContainer.contentSize = CGSizeMake(320, 508);
    
    [_viewWaiting setHidden:YES];
    
    [self displayUserInfo];
    
    _btnPurchase.enabled = NO;
    [self fetchProduct];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Credits_Changed object:nil];
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
    [self resignFirstResponderOfAllTexts];
}

- (IBAction)onBack:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    [_viewWaiting setHidden:NO];
    
    PFUser *user = [PFUser currentUser];
    user[@"f_name"] = _txtFullName.text;
    user[@"f_name_l"] = _txtFullName.text.lowercaseString;
    user.email = _txtEmail.text;
    user[@"phone"] = _txtPhoneNumber.text;
    if (genderIndex == 0)
        user[@"gender"] = [NSNumber numberWithBool:YES];
    else
        user[@"gender"] = [NSNumber numberWithBool:NO];
    if (onlineStatusIndex == 0)
        user[@"online_status"] = [NSNumber numberWithInt:USER_AVAILABLE|USER_ONLINE];
    else if (onlineStatusIndex == 1)
        user[@"online_status"] = [NSNumber numberWithInt:USER_DONTDISTURB|USER_ONLINE];
    else
        user[@"online_status"] = [NSNumber numberWithInt:USER_AWAYFROM|USER_ONLINE];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_viewWaiting setHidden:YES];
        if (!succeeded)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to update user profile." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)onSelectPhoto:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    PhotoPickerViewController *photoPickerController = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    photoPickerController.delegate = self;
    [self presentViewController:photoPickerController animated:YES completion:^{
    }];
}

- (IBAction)onAddCredits:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    if (![SKPaymentQueue canMakePayments])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Purchases are disabled in your device." message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (validProduct == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"No valid product to purchase." message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction)onStatusOnline:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    onlineStatusIndex = 0;
    [_btnOnline setSelected:YES];
    [_btnBusy setSelected:NO];
    [_btnAway setSelected:NO];
}

- (IBAction)onStatusBusy:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    onlineStatusIndex = 1;
    [_btnOnline setSelected:NO];
    [_btnBusy setSelected:YES];
    [_btnAway setSelected:NO];
}

- (IBAction)onStatusAway:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    onlineStatusIndex = 2;
    [_btnOnline setSelected:NO];
    [_btnBusy setSelected:NO];
    [_btnAway setSelected:YES];
}

- (IBAction)onGenderMale:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    genderIndex = 0;
    [_btnMale setSelected:YES];
    [_btnFemale setSelected:NO];
}

- (IBAction)onGenderFemale:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    genderIndex = 1;
    [_btnMale setSelected:NO];
    [_btnFemale setSelected:YES];
}

- (IBAction)onLogout:(id)sender
{
    [self resignFirstResponderOfAllTexts];
    
    [APP_DELEGATE logoutUser];
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

- (void)keyboardWillShow {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = _scrollContainer.frame;
    rect.size.height -= kOFFSET_FOR_KEYBOARD;
    _scrollContainer.frame = rect;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = _scrollContainer.frame;
    rect.size.height += kOFFSET_FOR_KEYBOARD;
    _scrollContainer.frame = rect;
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtFullName)
        [_txtEmail becomeFirstResponder];
    else if (textField == _txtEmail)
        [_txtPhoneNumber becomeFirstResponder];
    else
        [self resignFirstResponderOfAllTexts];
    return YES;
}

- (void)resignFirstResponderOfAllTexts
{
    [_txtFullName resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtPhoneNumber resignFirstResponder];
}

- (void)displayUserInfo
{
    PFUser *user = [PFUser currentUser];
    
    PFFile *photoFile = user[@"photo"];
    if (photoFile.isDataAvailable)
        [_btnPhoto setImage:[UIImage imageWithData:[photoFile getData]] forState:UIControlStateNormal];
    else
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data == nil)
                [_btnPhoto setImage:[UIImage imageNamed:@"user_dummy.png"] forState:UIControlStateNormal];
            else
                [_btnPhoto setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }];
    
    NSString *strFullName = user[@"f_name"];
    if (strFullName == nil)
        strFullName = @"";
    _txtFullName.text = strFullName;
    
    NSString *strEmail = user.email;
    if (strEmail == nil)
        strEmail = @"";
    _txtEmail.text = strEmail;
    
    NSString *strPhoneNumber = user[@"phone"];
    if (strPhoneNumber == nil)
        strPhoneNumber = @"";
    _txtPhoneNumber.text = strPhoneNumber;
    
    NSNumber *gender = user[@"gender"];
    if (gender == nil ||
        [gender boolValue] == YES)
    {
        genderIndex = 0;
        [_btnMale setSelected:YES];
        [_btnFemale setSelected:NO];
    }
    else
    {
        genderIndex = 0;
        [_btnMale setSelected:NO];
        [_btnFemale setSelected:YES];
    }
    
    int online_status = [user[@"online_status"] intValue];
    online_status = online_status & ~USER_ONLINE;
    if (online_status == USER_AVAILABLE)
    {
        onlineStatusIndex = 0;
        [_btnOnline setSelected:YES];
        [_btnBusy setSelected:NO];
        [_btnAway setSelected:NO];
    }
    else if (online_status == USER_DONTDISTURB)
    {
        onlineStatusIndex = 1;
        [_btnOnline setSelected:NO];
        [_btnBusy setSelected:YES];
        [_btnAway setSelected:NO];
    }
    else
    {
        onlineStatusIndex = 2;
        [_btnOnline setSelected:NO];
        [_btnBusy setSelected:NO];
        [_btnAway setSelected:YES];
    }
    
    NSNumber *scores = user[@"scores"];
    int num_scores = 0;
    if (scores != nil)
        num_scores = [scores intValue];
    _lblScores.text = [NSString stringWithFormat:@"%d", num_scores];
    
    NSNumber *credits = user[@"credits"];
    int num_credits = 0;
    if (credits != nil)
        num_credits = [credits intValue];
    _lblCredits.text = [NSString stringWithFormat:@"%d", num_credits];
}

- (void)photoPickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        HFImageEditorViewController *imageEditorController = [[HFImageEditorViewController alloc] initWithNibName:@"ImageCropViewController" bundle:nil];
        [imageEditorController setCropSize:CGSizeMake(240, 240)];
        [imageEditorController setSourceImage:image];
        [imageEditorController setPreviewImage:image];
        [imageEditorController reset:NO];
        [imageEditorController setDoneCallback:^(UIImage *editedImage, BOOL canceled) {
            if (!canceled)
            {
                [_viewWaiting setHidden:NO];
                PFUser *user = [PFUser currentUser];
                user[@"photo"] = [PFFile fileWithData:UIImageJPEGRepresentation(editedImage, .5f)];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [_viewWaiting setHidden:YES];
                    if (succeeded)
                        [_btnPhoto setImage:editedImage forState:UIControlStateNormal];
                }];
            }
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        [self presentViewController:imageEditorController animated:YES completion:^{
        }];
    }];
}

- (void)photoPickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)fetchProduct
{
    NSSet *productIdentifiers = [NSSet setWithObjects:kBuyCreditsProductId, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    int count = (int)[response.products count];
    if (count > 0)
    {
        NSArray *products = response.products;
        validProduct = [products objectAtIndex:0];
        _btnPurchase.enabled = YES;
    }
    else
    {
        UIAlertView *tmp = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"No products to purchase" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [tmp show];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                if ([transaction.payment.productIdentifier isEqualToString:kBuyCreditsProductId])
                {
                    NSLog(@"Purchased");
                    [self purchaseSucceeded];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed");
                break;
            default:
                break;
        }
    }
}

- (void)purchaseSucceeded
{
    PFUser *currentUser = [PFUser currentUser];
    int currentCredits = [currentUser[@"credits"] intValue];
    currentCredits += 10;
    currentUser[@"credits"] = [NSNumber numberWithInt:currentCredits];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil ||
            succeeded == NO)
        {
            NSLog(@"Save failed.");
            [currentUser saveEventually];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Credits_Changed object:nil];
    }];
}

- (void)onCreditsChanged:(NSNotification *)notification
{
    _lblCredits.text = [NSString stringWithFormat:@"%d", [[PFUser currentUser][@"credits"] intValue]];
}

@end
