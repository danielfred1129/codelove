//
//  TransitionController.m
//  Chatlenge
//
//  Created by lion on 6/12/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "TransitionController.h"

@implementation TransitionController

@synthesize containerView = _containerView,
viewController = _viewController;

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    _containerView = [[UIView alloc] initWithFrame:view.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_containerView];
    [_containerView addSubview:self.viewController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)transitionToViewController:(UIViewController *)aViewController
                       withOptions:(UIViewAnimationOptions)options
{
    aViewController.view.frame = self.containerView.bounds;
    [UIView transitionWithView:self.containerView
                      duration:1.f
                       options:options
                    animations:^{
                        [self.viewController.view removeFromSuperview];
                        [self.containerView addSubview:aViewController.view];
                    }
                    completion:^(BOOL finished){
                        self.viewController = aViewController;
                    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
