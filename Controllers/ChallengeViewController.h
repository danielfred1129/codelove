//
//  ChallengeViewController.h
//  Chatlenge
//
//  Created by lion on 7/15/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PickChallengeViewController.h"
#import "PhotoPickerViewController.h"

@interface ChallengeViewController : UIViewController <UITableViewDataSource,
                                                       UITableViewDelegate,
                                                       UITextFieldDelegate,
                                                       UIAlertViewDelegate,
                                                       PickChallengeControllerDelegate,
                                                       PhotoPickerControllerDelegate>
{
    NSArray *arrayChallenges;
}

@property (nonatomic, strong) PFUser *selectedUser;
@property (nonatomic, strong) UIViewController *superViewController;
@property (nonatomic, assign) BOOL isShown;

@property (strong, nonatomic) IBOutlet UITableView *tableChallenges;

@end
