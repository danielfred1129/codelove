//
//  ContactsViewController.h
//  Chatlenge
//
//  Created by lion on 6/11/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "FriendUsersTableViewCell.h"

@interface ContactsViewController : UIViewController <UITableViewDelegate,
                                                      UITableViewDataSource,
                                                      FriendUsersTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UITableView *tableUsers;

- (IBAction)onProfile:(id)sender;
- (IBAction)onSearch:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
