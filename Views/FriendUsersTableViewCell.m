//
//  FriendUsersTableViewCell.m
//  Chatlenge
//
//  Created by lion on 7/7/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "FriendUsersTableViewCell.h"

@implementation FriendUsersTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)onAvatar:(id)sender
{
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(onAvatar:)])
        [_delegate onAvatar:self.tag];
}

@end
