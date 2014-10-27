//
//  HistoryData.h
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface HistoryData : NSObject

@property (nonatomic, strong) PFObject *lastMessage;
@property (nonatomic, strong) PFObject *lastShownMessage;
@property (nonatomic, strong) PFObject *lastChallenge;
@property (nonatomic, strong) PFObject *lastShownChallenge;
@property (nonatomic, assign) long unsolvedChallengeCount;

@end
