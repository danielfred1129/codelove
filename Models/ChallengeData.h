//
//  ChallengeData.h
//  Chatlenge
//
//  Created by lion on 7/23/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ChallengeData : NSObject

@property (nonatomic, strong) PFObject *challengeObject;
@property (nonatomic, strong) NSMutableArray *arrayMessages;

@end
