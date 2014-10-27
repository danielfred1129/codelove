//
//  TransitionController.h
//  Chatlenge
//
//  Created by lion on 6/12/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionController : UIViewController

@property (nonatomic, strong) UIView * containerView;
@property (nonatomic, strong) UIViewController * viewController;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)transitionToViewController:(UIViewController *)viewController
                       withOptions:(UIViewAnimationOptions)options;

- (BOOL) prefersStatusBarHidden;

@end
