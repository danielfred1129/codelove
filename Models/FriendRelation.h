//
//  FriendRelation.h
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface FriendRelation : NSObject

@property (nonatomic, strong) NSString *relationId;
@property (nonatomic, strong) PFUser *friendUser;
@property (nonatomic, assign) BOOL isRequested;
@property (nonatomic, assign) BOOL isAccepted;

@end
