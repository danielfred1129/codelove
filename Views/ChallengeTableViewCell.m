//
//  ChallengeTableViewCell.m
//  Chatlenge
//
//  Created by lion on 7/22/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "ChallengeTableViewCell.h"

@implementation ChallengeTableViewCell

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

@end
