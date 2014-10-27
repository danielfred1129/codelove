//
//  FriendRelation.m
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"

#define kSecondsPerDay              (24*60*60)

static NSMutableArray *arrayFriendRelations = nil;
static NSMutableDictionary *dictionaryHistoryData = nil;

@implementation Globals

+ (NSMutableArray *)arrayFriendRelations
{
    return arrayFriendRelations;
}

+ (void)setArrayFriendRelations:(NSMutableArray *)array
{
    arrayFriendRelations = array;
}

+ (NSMutableDictionary *)dictionaryHistoryData
{
    return dictionaryHistoryData;
}

+ (void)setDictionaryHistoryData:(NSMutableDictionary *)dictionary
{
    dictionaryHistoryData = dictionary;
}

+ (NSString *)stringOfTime:(NSDate *)date
{
    NSString *result = @"";
    
    NSDate *currentTime = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *mComponents = [calendar components:(NSCalendarUnitYear |
                                                          NSCalendarUnitMonth |
                                                          NSCalendarUnitDay |
                                                          NSCalendarUnitHour |
                                                          NSCalendarUnitMinute |
                                                          NSCalendarUnitSecond) fromDate:date];
    [mComponents setHour:0];
    [mComponents setMinute:0];
    [mComponents setSecond:0];
    NSDateComponents *cComponents = [calendar components:(NSCalendarUnitYear |
                                                          NSCalendarUnitMonth |
                                                          NSCalendarUnitDay |
                                                          NSCalendarUnitHour |
                                                          NSCalendarUnitMinute |
                                                          NSCalendarUnitSecond) fromDate:currentTime];
    [cComponents setHour:0];
    [cComponents setMinute:0];
    [cComponents setSecond:0];
    [mComponents setCalendar:calendar];
    [cComponents setCalendar:calendar];
    NSDate *adjustedLastMessageTime = [mComponents date];
    NSDate *adjustedCurrentTime = [cComponents date];
    NSInteger timeInterval = (NSInteger)[adjustedCurrentTime timeIntervalSinceDate:adjustedLastMessageTime];
    if (timeInterval < kSecondsPerDay)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        result = [dateFormatter stringFromDate:date];
    }
    else if (timeInterval < (kSecondsPerDay * 2))
    {
        result = @"Yesterday";
    }
    else if (timeInterval < (kSecondsPerDay * 7))
    {
        long days = timeInterval / kSecondsPerDay;
        result = [NSString stringWithFormat:@"%ld days ago", days];
    }
    else if (timeInterval < (kSecondsPerDay * 30))
    {
        long weeks = timeInterval / (kSecondsPerDay * 7);
        if (weeks == 1)
            result = @"Last week";
        else
            result = [NSString stringWithFormat:@"%ld weeks ago", weeks];
    }
    else if (timeInterval < (kSecondsPerDay * 365))
    {
        long months = timeInterval / (kSecondsPerDay * 30);
        if (months == 1)
            result = @"Last month";
        else
            result = [NSString stringWithFormat:@"%ld months ago", months];
    }
    else
    {
        long years = timeInterval / (kSecondsPerDay * 365);
        if (years == 1)
            result = @"Last year";
        else
            result = [NSString stringWithFormat:@"%ld years ago", years];
    }
    
    return result;
}

+ (NSString *)displayNameForUser:(PFUser *)user
{
    NSString *fullName = user[@"f_name"];
    if (fullName == nil || [fullName isEqualToString:@""])
        return user.username;
    return fullName;
}

@end
