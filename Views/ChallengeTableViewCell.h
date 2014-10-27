//
//  ChallengeTableViewCell.h
//  Chatlenge
//
//  Created by lion on 7/22/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIImageView *imgChallengeType;
@property (strong, nonatomic) IBOutlet UILabel *lblChallengeType;
@property (strong, nonatomic) IBOutlet UIView *viewContentsContainer;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhase;
@property (strong, nonatomic) IBOutlet UILabel *lblPhase;
@property (strong, nonatomic) IBOutlet UIImageView *imgForceSolved;

@end
