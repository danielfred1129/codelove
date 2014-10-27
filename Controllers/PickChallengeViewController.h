//
//  PickChallengeViewController.h
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ChallengeData.h"

@protocol PickChallengeControllerDelegate <NSObject, UINavigationControllerDelegate>

- (void)didFinishPickingChallenge:(ChallengeData *)challenge;
- (void)didCancelPickingChallenge;

@end

@interface PickChallengeViewController : UINavigationController

@property (nonatomic, assign) id<PickChallengeControllerDelegate> delegate;
@property (nonatomic, strong) PFUser *selectedUser;

@end
