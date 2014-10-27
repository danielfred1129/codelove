//
//  ChallengeInfoPluginView.h
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallengeInfoPluginView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imgChallengeType;
@property (strong, nonatomic) IBOutlet UILabel *lblChallengeTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgChallengePhase;
@property (strong, nonatomic) IBOutlet UIButton *btnGotoChallenge;

@end
