//
//  MessageViewController.h
//  Chatlenge
//
//  Created by lion on 7/15/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PhotoPickerViewController.h"

@interface MessageViewController : UIViewController <UITextFieldDelegate,
                                                     UITableViewDataSource,
                                                     UITableViewDelegate,
                                                     PhotoPickerControllerDelegate>
{
    NSArray *arrayMessages;
}

@property (nonatomic, strong) PFUser *selectedUser;
@property (nonatomic, strong) UIViewController *superViewController;
@property (nonatomic, assign) BOOL isShown;

@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet UITableView *tableMessages;
@property (strong, nonatomic) IBOutlet UITextField *txtMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;

- (IBAction)onSendMessage:(id)sender;
- (IBAction)onSendPhoto:(id)sender;

@end
