//
//  Globals.h
//  Chatlenge
//
//  Created by lion on 7/8/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#ifndef Chatlenge_Globals_h
#define Chatlenge_Globals_h

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

// macro defines
#define kOFFSET_FOR_KEYBOARD    216.0
#define kRESTRICT_PHOTO_SIZE    480

// Receives this notification when the app become active
#define kNotification_Application_Active            @"Notification_Application_Active"
// Receives this notification when remote notification is received
#define kNotification_Remote_Notification           @"Notification_Remote_Notification"
// Contacts screen sends this notification when it reloads friend relationships
#define kNotification_Contacts_Reloaded             @"Notification_Contacts_Reloaded"
// Contacts screen sends this notification when the history data changed
#define kNotification_HistoryData_Changed           @"Notification_HistoryData_Changed"
// Contacts screen receives this notification when the contact operation is made on self-side.
#define kNotification_Self_Contacts_Reloaded        @"Notification_Self_Contacts_Reloaded"
// Contacts screen receives this notification when the history update (e.g. last shown message) is made on self-side.
#define kNotification_Self_History_Changed          @"Notification_Self_History_Changed"
// Contacts screen sends this notification when it receives message/challenge from any user
#define kNotification_Message_Received              @"Notification_Message_Received"
#define kNotification_Challenge_Changed             @"Notification_Challenge_Changed"
// Link notifications
#define kNotification_Link_Challenge                @"Notification_Link_Challenge"
#define kNotification_Link_Message                  @"Notification_Link_Message"
// Credits has been used or purchased
#define kNotification_Credits_Changed               @"Notification_Credits_Changed"

// Chatlenge greeting user id
#define kDefaultChatlengeUserId                     @"jVr9f1dzQt"

// account status enumeration
enum {
    ACCOUNT_INACTIVE,
    ACCOUNT_SUSPENDED,
    ACCOUNT_ACTIVE,
};

// user type enumeration
enum {
    USER_TYPE_NORMAL,
    USER_TYPE_FACEBOOK,
    USER_TYPE_TWITTER,
};

// online status enumeration
enum {
    USER_OFFLINE = 0,
    USER_ONLINE = 1,
};

// user available status
enum {
    USER_AVAILABLE = 0,
    USER_DONTDISTURB = 2,
    USER_AWAYFROM = 4
};

// notification type
enum {
    NOTIFY_REQUEST_FRIEND = 0,
    NOTIFY_CANCEL_REQUEST = 1,
    NOTIFY_ACCEPT_REQUEST = 2,
    NOTIFY_REJECT_REQUEST = 3,
    NOTIFY_REMOVE_FRIEND = 4,
    
    NOTIFY_INSTANT_MESSAGE = 5,
    
    NOTIFY_CHALLENGE_CHANGED = 6,
};

// media type
enum {
    MEDIA_TEXT = 0,
    MEDIA_PHOTO = 1,
    MEDIA_TIME = 2,
};

// challenge type
enum {
    QUEST_CHALLENGE = 0,        // question challenge
    EVID_CHALLENGE = 1,         // evidence challenge
    DATE_CHALLENGE = 2,         // date challenge
};

// challenge phase
enum {
    CHALLENGE_SUGGESTED = 0,
    CHALLENGE_ANSWERED = 1,
    CHALLENGE_SOLVED = 2,
};

@interface Globals : NSObject

+ (NSMutableArray *)arrayFriendRelations;
+ (void)setArrayFriendRelations:(NSMutableArray *)array;
+ (NSMutableDictionary *)dictionaryHistoryData;
+ (void)setDictionaryHistoryData:(NSMutableDictionary *)dictionary;

+ (NSString *)displayNameForUser:(PFUser *)user;
+ (NSString *)stringOfTime:(NSDate *)date;

@end

#endif
