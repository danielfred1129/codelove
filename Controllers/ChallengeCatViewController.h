//
//  ChallengeCatViewController.h
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeCatViewController : UIViewController <UITableViewDataSource,
                                                          UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UIImageView *imgUserPhoto;

- (IBAction)onBack:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
