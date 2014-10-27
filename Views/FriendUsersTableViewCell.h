//
//  FriendUsersTableViewCell.h
//  Chatlenge
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendUsersTableViewCellDelegate <NSObject>

- (void)onAvatar:(NSInteger)index;

@end

@interface FriendUsersTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblUsername;
@property (strong, nonatomic) IBOutlet UILabel *lblLastmessage;
@property (strong, nonatomic) IBOutlet UIImageView *imgStatus;
@property (strong, nonatomic) IBOutlet UILabel *lblScore;
@property (strong, nonatomic) IBOutlet UILabel *lblChallenges;
@property (strong, nonatomic) IBOutlet UILabel *lblLasttime;
@property (strong, nonatomic) IBOutlet UIImageView *imgAccessory;

@property (assign, nonatomic) id<FriendUsersTableViewCellDelegate> delegate;

- (IBAction)onAvatar:(id)sender;

@end
