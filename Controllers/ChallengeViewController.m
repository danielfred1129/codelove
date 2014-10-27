//
//  ChallengeViewController.m
//  Chatlenge
//
//  Created by lion on 7/15/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "Globals.h"
#import "AppDelegate.h"
#import "FriendRelation.h"
#import "HistoryData.h"
#import "ChallengeViewController.h"
#import "ChallengeTableViewCell.h"
#import "InputAnswerPluginView.h"
#import "TwoButtonPluginView.h"
#import "OneButtonPluginView.h"
#import "UIImage+Extension.h"

#define kContents_Gap               16.f

#define kStartTag_AcceptAnswer      10000
#define kStartTag_RejectAnswer      20000
#define kStartTag_ForceUnlock       30000

#define kStartTag_AnswerEvidence    10000

@interface ChallengeViewController ()
{
    NSTimer *timerDateChallenge;
}
@end

@implementation ChallengeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrayChallenges = nil;
        _isShown = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive:) name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChallengeChanged:) name:kNotification_Challenge_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLinkChallenge:) name:kNotification_Link_Challenge object:nil];
    
    _isShown = NO;
    [self refreshAllChallenges];
    
    timerDateChallenge = [NSTimer scheduledTimerWithTimeInterval:60.f target:self selector:@selector(onDateChallengeTimer:) userInfo:nil repeats:YES];
}

- (void)dealloc
{
    [timerDateChallenge invalidate];
    timerDateChallenge = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Application_Active object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Challenge_Changed object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_Link_Challenge object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TableView delegate implementations
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrayChallenges == nil)
        return 1;
    else
        return (arrayChallenges.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((arrayChallenges == nil && indexPath.row == 0) ||
        (arrayChallenges != nil && indexPath.row == arrayChallenges.count))
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChallengeTableViewCellPlus"];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChallengeTableViewCellPlus"];
        
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 70.f);
        UIButton *buttonPlus = [[UIButton alloc] initWithFrame:CGRectMake(135, 10, 50, 50)];
        [buttonPlus setImage:[UIImage imageNamed:@"add_unlock_btn.png"] forState:UIControlStateNormal];
        [buttonPlus addTarget:self action:@selector(onAddChallenge:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:buttonPlus];
        
        return cell;
    }

    if (arrayChallenges == nil)
        return nil;
    
    PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - indexPath.row)];
    BOOL isIncoming = YES;
    PFObject *fromUserObject = challengeObject[@"from_user"];
    if ([fromUserObject.objectId isEqualToString:[PFUser currentUser].objectId])
        isIncoming = NO;
    
    ChallengeTableViewCell *cell = nil;
    if (isIncoming)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChallengeTableViewCellIn"];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeTableViewCellIn" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChallengeTableViewCellOut"];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChallengeTableViewCellOut" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
    }
    
    [cell.viewContentsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (isIncoming)
        cell.imgBackground.image = [[UIImage imageNamed:@"bubble_challenge_in.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    else
        cell.imgBackground.image = [[UIImage imageNamed:@"bubble_challenge_out.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    
    int challengePhase = [challengeObject[@"phase"] intValue];
    if (challengePhase == CHALLENGE_SUGGESTED)
    {
        cell.imgPhase.image = [UIImage imageNamed:@"busy_mark.png"];
        cell.lblPhase.text = @"Challenged";
        cell.imgForceSolved.image = nil;
    }
    else if (challengePhase == CHALLENGE_ANSWERED)
    {
        cell.imgPhase.image = [UIImage imageNamed:@"away_mark.png"];
        cell.lblPhase.text = @"Answered";
        cell.imgForceSolved.image = nil;
    }
    else if (challengePhase == CHALLENGE_SOLVED)
    {
        cell.imgPhase.image = [UIImage imageNamed:@"online_mark.png"];
        cell.lblPhase.text = @"Solved";
        BOOL isForceSolved = [challengeObject[@"force_solved"] boolValue];
        if (isForceSolved)
            cell.imgForceSolved.image = [UIImage imageNamed:@"unlock_mark.png"];
        else
            cell.imgForceSolved.image = nil;
    }
    else
    {
        cell.imgPhase.image = nil;
        cell.lblPhase.text = nil;
        cell.imgForceSolved.image = nil;
    }
    
    int challengeType = [challengeObject[@"challenge_type"] intValue];
    if (challengeType == QUEST_CHALLENGE)
    {
        if (isIncoming)
            cell.imgChallengeType.image = [UIImage imageNamed:@"q_challenge_in_mark.png"];
        else
            cell.imgChallengeType.image = [UIImage imageNamed:@"q_challenge_out_mark.png"];
        cell.lblChallengeType.text = @"Question";
    }
    else if (challengeType == EVID_CHALLENGE)
    {
        if (isIncoming)
            cell.imgChallengeType.image = [UIImage imageNamed:@"e_challenge_in_mark.png"];
        else
            cell.imgChallengeType.image = [UIImage imageNamed:@"e_challenge_out_mark.png"];
        cell.lblChallengeType.text = @"Evidence";
    }
    else if (challengeType == DATE_CHALLENGE)
    {
        if (isIncoming)
            cell.imgChallengeType.image = [UIImage imageNamed:@"d_challenge_in_mark.png"];
        else
            cell.imgChallengeType.image = [UIImage imageNamed:@"d_challenge_out_mark.png"];
        cell.lblChallengeType.text = @"Date";
    }
    else
    {
        cell.imgChallengeType.image = nil;
        cell.lblChallengeType.text = nil;
    }
    
    CGFloat height = kContents_Gap / 2.f;
    
    // display challenge title.
    int suggestType = [challengeObject[@"suggest_type"] intValue];
    if (suggestType == MEDIA_TEXT ||
        suggestType == MEDIA_TIME)
    {
        NSString *strChallengeTitle = nil;
        if (suggestType == MEDIA_TEXT)
            strChallengeTitle = challengeObject[@"suggest_text"];
        else
        {
            NSDate *date = challengeObject[@"suggest_time"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            strChallengeTitle = [dateFormatter stringFromDate:date];
        }
        UILabel *lblChallengeTitle = [[UILabel alloc] init];
        lblChallengeTitle.font = [UIFont systemFontOfSize:13.f];
        lblChallengeTitle.text = strChallengeTitle;
        lblChallengeTitle.numberOfLines = 0;
        CGRect rcBounds = [lblChallengeTitle textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
        lblChallengeTitle.frame = CGRectMake(0, height, 180.f, rcBounds.size.height);
        lblChallengeTitle.textColor = [UIColor darkGrayColor];
        
        [cell.viewContentsContainer addSubview:lblChallengeTitle];
        
        height += rcBounds.size.height;
    }
    
    // display content
    if (challengePhase == CHALLENGE_SOLVED)
    {
        if (challengeType == QUEST_CHALLENGE)
        {
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
            viewLine.backgroundColor = [UIColor lightGrayColor];
            [cell.viewContentsContainer addSubview:viewLine];
            
            NSString *stringAnswer = challengeObject[@"answer_text"];
            
            UILabel *lblChallengeAnswer = [[UILabel alloc] init];
            lblChallengeAnswer.font = [UIFont systemFontOfSize:13.f];
            lblChallengeAnswer.text = stringAnswer;
            lblChallengeAnswer.numberOfLines = 0;
            CGRect rcBounds = [lblChallengeAnswer textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
            lblChallengeAnswer.frame = CGRectMake(0, height + kContents_Gap, 180.f, rcBounds.size.height);
            lblChallengeAnswer.textColor = [UIColor darkGrayColor];
            
            [cell.viewContentsContainer addSubview:lblChallengeAnswer];
            
            height += kContents_Gap + rcBounds.size.height;
        }
        else if (challengeType == EVID_CHALLENGE)
        {
            PFFile *photoFile = challengeObject[@"answer_image"];
            if (photoFile.isDataAvailable)
            {
                UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                viewLine.backgroundColor = [UIColor lightGrayColor];
                [cell.viewContentsContainer addSubview:viewLine];
                
                UIImage *photoImage = [UIImage imageWithData:[photoFile getData]];
                CGFloat img_width = photoImage.size.width / 2;
                CGFloat img_height = photoImage.size.height / 2;
                CGFloat scale = 180.f / img_width;
                img_width = 180.f;
                img_height = img_height * scale;
                
                UIImageView *imgAnswer = [[UIImageView alloc] initWithImage:photoImage];
                imgAnswer.frame = CGRectMake(0, height + kContents_Gap, img_width, img_height);
                imgAnswer.layer.masksToBounds = YES;
                imgAnswer.layer.cornerRadius = 5.f;
                
                [cell.viewContentsContainer addSubview:imgAnswer];
                
                height += kContents_Gap + img_height;
            }
            else
            {
                [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    [_tableChallenges reloadData];
                }];
            }
        }
        
        if (isIncoming)
        {
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
            viewLine.backgroundColor = [UIColor lightGrayColor];
            [cell.viewContentsContainer addSubview:viewLine];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TwoButtonPluginView" owner:self options:nil];
            TwoButtonPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
            [viewPlugin.button1 setImage:[UIImage imageNamed:@"fb_icon.png"] forState:UIControlStateNormal];
            viewPlugin.button1.tag = indexPath.row;
            [viewPlugin.button1 addTarget:self action:@selector(onPostFacebook:) forControlEvents:UIControlEventTouchUpInside];
            [viewPlugin.button2 setImage:[UIImage imageNamed:@"tw_icon.png"] forState:UIControlStateNormal];
            viewPlugin.button2.tag = indexPath.row;
            [viewPlugin.button2 addTarget:self action:@selector(onPostTwitter:) forControlEvents:UIControlEventTouchUpInside];
            viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
            [cell.viewContentsContainer addSubview:viewPlugin];
            
            height += kContents_Gap + 30.f;
        }
    }
    else
    {
        if (challengeType == QUEST_CHALLENGE)
        {
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
            viewLine.backgroundColor = [UIColor lightGrayColor];
            [cell.viewContentsContainer addSubview:viewLine];
            
            if (isIncoming == NO)
            {
                NSString *stringAnswer = challengeObject[@"answer_text"];
                
                UILabel *lblChallengeAnswer = [[UILabel alloc] init];
                lblChallengeAnswer.font = [UIFont systemFontOfSize:13.f];
                lblChallengeAnswer.text = stringAnswer;
                lblChallengeAnswer.numberOfLines = 0;
                CGRect rcBounds = [lblChallengeAnswer textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
                lblChallengeAnswer.frame = CGRectMake(0, height + kContents_Gap, 180.f, rcBounds.size.height);
                lblChallengeAnswer.textColor = [UIColor darkGrayColor];
                
                [cell.viewContentsContainer addSubview:lblChallengeAnswer];
                
                height += kContents_Gap + rcBounds.size.height;
            }
            else
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InputAnswerPluginView" owner:self options:nil];
                InputAnswerPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
                viewPlugin.txtAnswer.tag = indexPath.row;
                viewPlugin.txtAnswer.delegate = self;
                viewPlugin.btnUnlock.tag = indexPath.row;
                [viewPlugin.btnUnlock addTarget:self action:@selector(onForceUnlockChallenge:) forControlEvents:UIControlEventTouchUpInside];
                viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
                [cell.viewContentsContainer addSubview:viewPlugin];
                
                height += kContents_Gap + 30.f;
            }
        }
        else if (challengeType == EVID_CHALLENGE)
        {
            if (challengePhase == CHALLENGE_ANSWERED)
            {
                PFFile *photoFile = challengeObject[@"answer_image"];
                if (photoFile.isDataAvailable)
                {
                    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                    viewLine.backgroundColor = [UIColor lightGrayColor];
                    [cell.viewContentsContainer addSubview:viewLine];
                    
                    UIImage *photoImage = [UIImage imageWithData:[photoFile getData]];
                    CGFloat img_width = photoImage.size.width / 2;
                    CGFloat img_height = photoImage.size.height / 2;
                    CGFloat scale = 180.f / img_width;
                    img_width = 180.f;
                    img_height = img_height * scale;
                    
                    UIImageView *imgAnswer = [[UIImageView alloc] initWithImage:photoImage];
                    imgAnswer.frame = CGRectMake(0, height + kContents_Gap, img_width, img_height);
                    imgAnswer.layer.masksToBounds = YES;
                    imgAnswer.layer.cornerRadius = 5.f;
                    
                    [cell.viewContentsContainer addSubview:imgAnswer];
                    
                    height += kContents_Gap + img_height;
                }
                else
                {
                    [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        [_tableChallenges reloadData];
                    }];
                }
                
                if (isIncoming == NO)
                {
                    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                    viewLine.backgroundColor = [UIColor lightGrayColor];
                    [cell.viewContentsContainer addSubview:viewLine];
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TwoButtonPluginView" owner:self options:nil];
                    TwoButtonPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
                    [viewPlugin.button1 setImage:[UIImage imageNamed:@"ok_btn.png"] forState:UIControlStateNormal];
                    viewPlugin.button1.tag = indexPath.row;
                    [viewPlugin.button1 addTarget:self action:@selector(onAcceptAnswer:) forControlEvents:UIControlEventTouchUpInside];
                    [viewPlugin.button2 setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
                    viewPlugin.button2.tag = indexPath.row;
                    [viewPlugin.button2 addTarget:self action:@selector(onRejectAnswer:) forControlEvents:UIControlEventTouchUpInside];
                    viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
                    [cell.viewContentsContainer addSubview:viewPlugin];
                    
                    height += kContents_Gap + 30.f;
                }
                else
                {
                    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                    viewLine.backgroundColor = [UIColor lightGrayColor];
                    [cell.viewContentsContainer addSubview:viewLine];
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TwoButtonPluginView" owner:self options:nil];
                    TwoButtonPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
                    [viewPlugin.button1 setImage:[UIImage imageNamed:@"take_photo_btn.png"] forState:UIControlStateNormal];
                    viewPlugin.button1.tag = indexPath.row;
                    [viewPlugin.button1 addTarget:self action:@selector(onTakePhotoForAnswer:) forControlEvents:UIControlEventTouchUpInside];
                    [viewPlugin.button2 setImage:[UIImage imageNamed:@"unlock_mark.png"] forState:UIControlStateNormal];
                    viewPlugin.button2.tag = indexPath.row;
                    [viewPlugin.button2 addTarget:self action:@selector(onForceUnlockChallenge:) forControlEvents:UIControlEventTouchUpInside];
                    viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
                    [cell.viewContentsContainer addSubview:viewPlugin];
                    
                    height += kContents_Gap + 30.f;
                }
            }
            else
            {
                if (isIncoming)
                {
                    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                    viewLine.backgroundColor = [UIColor lightGrayColor];
                    [cell.viewContentsContainer addSubview:viewLine];
                    
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TwoButtonPluginView" owner:self options:nil];
                    TwoButtonPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
                    [viewPlugin.button1 setImage:[UIImage imageNamed:@"take_photo_btn.png"] forState:UIControlStateNormal];
                    viewPlugin.button1.tag = indexPath.row;
                    [viewPlugin.button1 addTarget:self action:@selector(onTakePhotoForAnswer:) forControlEvents:UIControlEventTouchUpInside];
                    [viewPlugin.button2 setImage:[UIImage imageNamed:@"unlock_mark.png"] forState:UIControlStateNormal];
                    viewPlugin.button2.tag = indexPath.row;
                    [viewPlugin.button2 addTarget:self action:@selector(onForceUnlockChallenge:) forControlEvents:UIControlEventTouchUpInside];
                    viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
                    [cell.viewContentsContainer addSubview:viewPlugin];
                    
                    height += kContents_Gap + 30.f;
                }
            }
        }
        else if (challengeType == DATE_CHALLENGE)
        {
            if (isIncoming)
            {
                UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f), 160.f, 1.f)];
                viewLine.backgroundColor = [UIColor lightGrayColor];
                [cell.viewContentsContainer addSubview:viewLine];
                
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OneButtonPluginView" owner:self options:nil];
                OneButtonPluginView *viewPlugin = [topLevelObjects objectAtIndex:0];
                [viewPlugin.button setImage:[UIImage imageNamed:@"unlock_mark.png"] forState:UIControlStateNormal];
                viewPlugin.button.tag = indexPath.row;
                [viewPlugin.button addTarget:self action:@selector(onForceUnlockChallenge:) forControlEvents:UIControlEventTouchUpInside];
                viewPlugin.frame = CGRectMake(0, height + kContents_Gap, 180, 30);
                [cell.viewContentsContainer addSubview:viewPlugin];
                
                height += kContents_Gap + 30.f;
            }
        }
    }
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(10, height + (kContents_Gap / 2.f) - 1.f, 160.f, 1.f)];
    viewLine.backgroundColor = [UIColor lightGrayColor];
    [cell.viewContentsContainer addSubview:viewLine];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((arrayChallenges == nil && indexPath.row == 0) ||
        (arrayChallenges != nil && indexPath.row == arrayChallenges.count))
        return 240.f;
    
    CGSize contentSize = [self contentSizeForRowAtIndexPath:indexPath];
    return (contentSize.height + 60.f);
}

- (CGSize)contentSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arrayChallenges == nil)
        return CGSizeMake(180.f, 40.f);
    
    PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - indexPath.row)];
    int challengeType = [challengeObject[@"challenge_type"] intValue];
    int challengePhase = [challengeObject[@"phase"] intValue];
    BOOL isIncoming = YES;
    PFObject *fromUserObject = challengeObject[@"from_user"];
    if ([fromUserObject.objectId isEqualToString:[PFUser currentUser].objectId])
        isIncoming = NO;
    
    CGFloat height = kContents_Gap / 2.f;
    
    // get height of challenge title.
    int suggestType = [challengeObject[@"suggest_type"] intValue];
    if (suggestType == MEDIA_TEXT ||
        suggestType == MEDIA_TIME)
    {
        NSString *strChallengeTitle = nil;
        if (suggestType == MEDIA_TEXT)
            strChallengeTitle = challengeObject[@"suggest_text"];
        else
        {
            NSDate *date = challengeObject[@"suggest_time"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            strChallengeTitle = [dateFormatter stringFromDate:date];
        }
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.font = [UIFont systemFontOfSize:13.f];
        tempLabel.text = strChallengeTitle;
        tempLabel.numberOfLines = 0;
        CGRect rcBounds = [tempLabel textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
        tempLabel = nil;
        
        height += rcBounds.size.height;
    }
    
    // get height of content
    if (challengePhase == CHALLENGE_SOLVED)
    {
        if (challengeType == QUEST_CHALLENGE)
        {
            NSString *stringAnswer = challengeObject[@"answer_text"];
            
            UILabel *tempLabel = [[UILabel alloc] init];
            tempLabel.font = [UIFont systemFontOfSize:13.f];
            tempLabel.text = stringAnswer;
            tempLabel.numberOfLines = 0;
            CGRect rcBounds = [tempLabel textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
            tempLabel = nil;
            
            height += kContents_Gap + rcBounds.size.height;
        }
        else if (challengeType == EVID_CHALLENGE)
        {
            PFFile *photoFile = challengeObject[@"answer_image"];
            if (photoFile.isDataAvailable)
            {
                UIImage *photoImage = [UIImage imageWithData:[photoFile getData]];
                CGFloat img_width = photoImage.size.width / 2;
                CGFloat img_height = photoImage.size.height / 2;
                CGFloat scale = 180.f / img_width;
                img_width = 180.f;
                img_height = img_height * scale;
                height += kContents_Gap + img_height;
            }
        }
        
        if (isIncoming)
            height += kContents_Gap + 30.f;
    }
    else
    {
        if (challengeType == QUEST_CHALLENGE)
        {
            if (isIncoming == NO)
            {
                NSString *stringAnswer = challengeObject[@"answer_text"];
                
                UILabel *tempLabel = [[UILabel alloc] init];
                tempLabel.font = [UIFont systemFontOfSize:13.f];
                tempLabel.text = stringAnswer;
                tempLabel.numberOfLines = 0;
                CGRect rcBounds = [tempLabel textRectForBounds:CGRectMake(0, 0, 180.f, 9999.f) limitedToNumberOfLines:0];
                tempLabel = nil;
                
                height += kContents_Gap + rcBounds.size.height;
            }
            else
            {
                height += kContents_Gap + 30.f;
            }
        }
        else if (challengeType == EVID_CHALLENGE)
        {
            if (challengePhase == CHALLENGE_ANSWERED)
            {
                PFFile *photoFile = challengeObject[@"answer_image"];
                if (photoFile.isDataAvailable)
                {
                    UIImage *photoImage = [UIImage imageWithData:[photoFile getData]];
                    CGFloat img_width = photoImage.size.width / 2;
                    CGFloat img_height = photoImage.size.height / 2;
                    CGFloat scale = 180.f / img_width;
                    img_width = 180.f;
                    img_height = img_height * scale;
                    height += kContents_Gap + img_height;
                }
                
                height += kContents_Gap + 30.f;
            }
            else
            {
                if (isIncoming)
                    height += kContents_Gap + 30.f;
            }
        }
        else if (challengeType == DATE_CHALLENGE)
        {
            if (isIncoming)
                height += kContents_Gap + 30.f;
        }
    }
    
    height += kContents_Gap / 2.f;
    
    if (height < 40.f)
        height = 40.f;
    
    return CGSizeMake(180.f, height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    
    if (indexPath.row >= arrayChallenges.count)
        return;
    
    PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - indexPath.row)];
    
    PFUser *leftUser = challengeObject[@"from_user"];
    int challengePhase = [challengeObject[@"phase"] intValue];
    if (![leftUser.objectId isEqualToString:[PFUser currentUser].objectId] &&
        challengePhase != CHALLENGE_SOLVED)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Link_Message object:nil userInfo:@{@"challenge_id":challengeObject.objectId}];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)onAddChallenge:(id)sender
{
    [self.view endEditing:YES];
    
    PickChallengeViewController *pickChallengeController = [[PickChallengeViewController alloc] init];
    pickChallengeController.delegate = self;
    pickChallengeController.selectedUser = _selectedUser;
    [self.superViewController presentViewController:pickChallengeController animated:YES completion:nil];
}

- (void)onAcceptAnswer:(id)sender
{
    [self.view endEditing:YES];
    
    NSInteger focusedIndex = ((UIButton *)sender).tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"You are going to accept the answer." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
    alertView.tag = focusedIndex + kStartTag_AcceptAnswer;
    [alertView show];
}

- (void)onRejectAnswer:(id)sender
{
    [self.view endEditing:YES];
    
    NSInteger focusedIndex = ((UIButton *)sender).tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"You are going to reject the answer." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
    alertView.tag = focusedIndex + kStartTag_RejectAnswer;
    [alertView show];
}

- (void)onPostFacebook:(id)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post on Facebook" message:@"Coming soon!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
    [alertView show];
}

- (void)onPostTwitter:(id)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post on Twitter" message:@"Coming soon!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
    [alertView show];
}

- (void)onTakePhotoForAnswer:(id)sender
{
    [self.view endEditing:YES];
    
    NSInteger focusedIndex = ((UIButton *)sender).tag;
    
    PhotoPickerViewController *photoPickerController = [[PhotoPickerViewController alloc] initWithNibName:@"PhotoPickerViewController" bundle:nil];
    photoPickerController.delegate = self;
    photoPickerController.view.tag = kStartTag_AnswerEvidence + focusedIndex;
    [_superViewController presentViewController:photoPickerController animated:YES completion:nil];
}

- (void)onForceUnlockChallenge:(id)sender
{
    [self.view endEditing:YES];
    
    NSInteger focusedIndex = ((UIButton *)sender).tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unlock challenge" message:@"Are you sure to unlock this challenge by spending some credits?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
    alertView.tag = kStartTag_ForceUnlock + focusedIndex;
    [alertView show];
}

- (void)setIsShown:(BOOL)isShown
{
    [self.view endEditing:YES];
    
    _isShown = isShown;
    if (isShown)
        [self updateLastShownChallenge];
}

- (void)onAppBecomeActive:(NSNotification *)notification
{
    [self refreshAllChallenges];
}

- (void)onChallengeChanged:(NSNotification *)notification
{
    [self refreshAllChallenges];
}

- (void)onLinkChallenge:(NSNotification *)notification
{
    if (arrayChallenges == nil)
        return;
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *challengeId = [userInfo objectForKey:@"challenge_id"];
    int challengeIndex = -1;
    for (int i = 0; i < arrayChallenges.count; i ++)
    {
        PFObject *challengeObject = [arrayChallenges objectAtIndex:i];
        if ([challengeObject.objectId isEqualToString:challengeId])
        {
            challengeIndex = i;
            break;
        }
    }
    if (challengeIndex == -1)
        return;
    
    [_tableChallenges scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayChallenges.count - 1 - challengeIndex) inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.text isEqualToString:@""])
        return YES;
    
    NSString *strAnswer = textField.text;
    NSInteger focusedIndex = textField.tag;
    PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - focusedIndex)];
    if ([challengeObject[@"challenge_type"] intValue] != QUEST_CHALLENGE)
        return YES;
    NSString *strExpectedAnswer = challengeObject[@"answer_text"];
    
    strAnswer = [strAnswer stringByReplacingOccurrencesOfString:@" " withString:@""];
    strAnswer = [strAnswer lowercaseString];
    strExpectedAnswer = [strExpectedAnswer stringByReplacingOccurrencesOfString:@" " withString:@""];
    strExpectedAnswer = [strExpectedAnswer lowercaseString];
    if ([strAnswer isEqualToString:strExpectedAnswer])
    {
        // answer matched.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Correct answer!" message:@"Congratulations! Your answer is right." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alertView show];
        
        challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SOLVED];
        [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFQuery *queryMessages = [PFQuery queryWithClassName:@"chat_history"];
            [queryMessages whereKey:@"challenge" equalTo:challengeObject];
            [queryMessages orderByAscending:@"updatedAt"];
            [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects == nil)
                {
                    NSString *strMessage = [NSString stringWithFormat:@"%@ provided right answer for your challenge!", [Globals displayNameForUser:[PFUser currentUser]]];
                    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Remote_Notification object:nil userInfo:@{@"type":[NSNumber numberWithInt:NOTIFY_CHALLENGE_CHANGED], @"from_user":_selectedUser.objectId}];
                }
                else
                {
                    __block int updateCount = 0;
                    for (int i = 0; i < objects.count; i ++)
                    {
                        PFObject *messageObject = [objects objectAtIndex:i];
                        messageObject[@"challenge_solved"] = @YES;
                        [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            updateCount ++;
                            NSLog(@"updateCount = %d", updateCount);
                            if (updateCount >= objects.count)
                            {
                                NSLog(@"All update has been finished.");
                                
                                NSString *strMessage = [NSString stringWithFormat:@"%@ provided right answer for your challenge!", [Globals displayNameForUser:[PFUser currentUser]]];
                                [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Remote_Notification object:nil userInfo:@{@"type":[NSNumber numberWithInt:NOTIFY_CHALLENGE_CHANGED], @"from_user":_selectedUser.objectId}];
                            }
                        }];
                    }
                }
            }];
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Wrong answer!" message:@"Your answer is wrong. Please try again!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alertView show];
    }
    
    return YES;
}

- (void)didFinishPickingChallenge:(ChallengeData *)challenge
{
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *arrayChallengeMessages = challenge.arrayMessages;
    PFObject *challengeObject = challenge.challengeObject;
    [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil || !succeeded)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed to set new challenge! Please check your network connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return;
        }
        
        __block int saveCount = 0;
        for (int i = 0; i < arrayChallengeMessages.count; i ++)
        {
            PFObject *messageObject = [arrayChallengeMessages objectAtIndex:i];
            messageObject[@"challenge"] = challengeObject;
            messageObject[@"challenge_solved"] = @NO;
            [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                saveCount ++;
                NSLog(@"saveCount = %d", saveCount);
                if (saveCount == arrayChallengeMessages.count)
                {
                    NSLog(@"All saved.");
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
                    
                    NSString *strMessage = [NSString stringWithFormat:@"%@ challenged you.", [Globals displayNameForUser:[PFUser currentUser]]];
                    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                }
            }];
        }
    }];
}

- (void)didCancelPickingChallenge
{
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag >= kStartTag_AcceptAnswer &&
        alertView.tag < kStartTag_RejectAnswer)
    {
        if (buttonIndex == 1)
            return;
        
        NSInteger focusedIndex = alertView.tag - kStartTag_AcceptAnswer;
        PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - focusedIndex)];
        
        challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SOLVED];
        [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFQuery *queryMessages = [PFQuery queryWithClassName:@"chat_history"];
            [queryMessages whereKey:@"challenge" equalTo:challengeObject];
            [queryMessages orderByAscending:@"updatedAt"];
            [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects == nil)
                {
                    NSString *strMessage = [NSString stringWithFormat:@"%@ accepted your answer.", [Globals displayNameForUser:[PFUser currentUser]]];
                    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
                }
                else
                {
                    __block int updateCount = 0;
                    for (int i = 0; i < objects.count; i ++)
                    {
                        PFObject *messageObject = [objects objectAtIndex:i];
                        messageObject[@"challenge_solved"] = @YES;
                        [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            updateCount ++;
                            NSLog(@"updateCount = %d", updateCount);
                            if (updateCount >= objects.count)
                            {
                                NSLog(@"All update has been finished.");
                                
                                NSString *strMessage = [NSString stringWithFormat:@"%@ accepted your answer.", [Globals displayNameForUser:[PFUser currentUser]]];
                                [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
                            }
                        }];
                    }
                }
            }];
        }];
    }
    else if (alertView.tag >= kStartTag_RejectAnswer &&
             alertView.tag < kStartTag_ForceUnlock)
    {
        if (buttonIndex == 1)
            return;
        
        NSInteger focusedIndex = alertView.tag - kStartTag_RejectAnswer;
        PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - focusedIndex)];
        
        challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SUGGESTED];
        [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSString *strMessage = [NSString stringWithFormat:@"%@ rejected your answer.", [Globals displayNameForUser:[PFUser currentUser]]];
            [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
        }];
    }
    else if (alertView.tag >= kStartTag_ForceUnlock)
    {
        if (buttonIndex == 1)
            return;
        
        NSInteger focusedIndex = alertView.tag - kStartTag_ForceUnlock;
        PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - focusedIndex)];
        
        int neededCredits = 0;
        int challengeType = [challengeObject[@"challenge_type"] intValue];
        if (challengeType == QUEST_CHALLENGE)
            neededCredits = 1;
        else if (challengeType == EVID_CHALLENGE)
            neededCredits = 2;
        else if (challengeType == DATE_CHALLENGE)
            neededCredits = 3;
        
        if (neededCredits <= 0)
            return;
        
        int credits = [[PFUser currentUser][@"credits"] intValue];
        if (credits < neededCredits)
        {
            NSString *strMessage = [NSString stringWithFormat:@"You need %d credits to unlock this challenge, but you have no enough. Please purchase credits on your profile page.", neededCredits];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unlock challenge" message:strMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
            [alertView show];
            return;
        }
        
        challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SOLVED];
        challengeObject[@"force_solved"] = @YES;
        [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFQuery *queryMessages = [PFQuery queryWithClassName:@"chat_history"];
            [queryMessages whereKey:@"challenge" equalTo:challengeObject];
            [queryMessages orderByAscending:@"updatedAt"];
            [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects == nil)
                {
                    PFUser *currentUser = [PFUser currentUser];
                    currentUser[@"credits"] = [NSNumber numberWithInt:(credits - neededCredits)];
                    [currentUser saveInBackground];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Credits_Changed object:nil];
                    
                    NSString *strMessage = [NSString stringWithFormat:@"%@ unlocked your challenge by credits.", [Globals displayNameForUser:[PFUser currentUser]]];
                    [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Remote_Notification object:nil userInfo:@{@"type":[NSNumber numberWithInt:NOTIFY_CHALLENGE_CHANGED], @"from_user":_selectedUser.objectId}];
                }
                else
                {
                    __block int updateCount = 0;
                    for (int i = 0; i < objects.count; i ++)
                    {
                        PFObject *messageObject = [objects objectAtIndex:i];
                        messageObject[@"challenge_solved"] = @YES;
                        [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            updateCount ++;
                            NSLog(@"updateCount = %d", updateCount);
                            if (updateCount >= objects.count)
                            {
                                NSLog(@"All update has been finished.");
                                
                                PFUser *currentUser = [PFUser currentUser];
                                currentUser[@"credits"] = [NSNumber numberWithInt:(credits - neededCredits)];
                                [currentUser saveInBackground];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Credits_Changed object:nil];
                                
                                NSString *strMessage = [NSString stringWithFormat:@"%@ unlocked your challenge by credits.", [Globals displayNameForUser:[PFUser currentUser]]];
                                [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Remote_Notification object:nil userInfo:@{@"type":[NSNumber numberWithInt:NOTIFY_CHALLENGE_CHANGED], @"from_user":_selectedUser.objectId}];
                            }
                        }];
                    }
                }
            }];
        }];
    }
}

- (void)photoPickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_superViewController dismissViewControllerAnimated:YES completion:^{
        UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
        if (picker.view.tag >= kStartTag_AnswerEvidence)
        {
            NSLog(@"Current size : %@", NSStringFromCGSize(image.size));
            CGSize newSize = image.size;
            if (newSize.width > kRESTRICT_PHOTO_SIZE)
            {
                CGFloat scale = kRESTRICT_PHOTO_SIZE / newSize.width;
                newSize.width = kRESTRICT_PHOTO_SIZE;
                newSize.height = newSize.height * scale;
            }
            /*if (newSize.height > kRESTRICT_PHOTO_SIZE)
             {
             CGFloat scale = kRESTRICT_PHOTO_SIZE / newSize.height;
             newSize.height = kRESTRICT_PHOTO_SIZE;
             newSize.width = newSize.width * scale;
             }*/
            NSLog(@"Resizing : %@", NSStringFromCGSize(newSize));
            UIImage *scaledPhoto = [[image fixOrientation] scaleToSize:newSize];
            NSLog(@"Resized : %@", NSStringFromCGSize(scaledPhoto.size));
            
            NSInteger focusedIndex = picker.view.tag - kStartTag_AnswerEvidence;
            PFObject *challengeObject = [arrayChallenges objectAtIndex:(arrayChallenges.count - 1 - focusedIndex)];
            challengeObject[@"answer_type"] = [NSNumber numberWithInt:MEDIA_PHOTO];
            challengeObject[@"answer_image"] = [PFFile fileWithData:UIImageJPEGRepresentation(scaledPhoto, .5f)];
            challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_ANSWERED];
            [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSString *strMessage = [NSString stringWithFormat:@"%@ provided answer for your evidence challenge.", [Globals displayNameForUser:[PFUser currentUser]]];
                [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil userInfo:nil];
            }];
        }
    }];
}

- (void)photoPickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [_superViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSArray *visibleCells = [_tableChallenges visibleCells];
    if (visibleCells == nil)
        return;
    
    NSInteger focusedIndex = -1;
    for (int i = 0; i < visibleCells.count; i ++)
    {
        UITableViewCell *vc = [visibleCells objectAtIndex:i];
        if (![vc isKindOfClass:[ChallengeTableViewCell class]])
            continue;
        ChallengeTableViewCell *cell = (ChallengeTableViewCell *)vc;
        for (int j = 0; j < cell.viewContentsContainer.subviews.count; j ++)
        {
            UIView *subView = [cell.viewContentsContainer.subviews objectAtIndex:j];
            if ([subView isKindOfClass:[InputAnswerPluginView class]])
            {
                InputAnswerPluginView *pluginView = (InputAnswerPluginView *)subView;
                if ([pluginView.txtAnswer isFirstResponder])
                {
                    focusedIndex = pluginView.txtAnswer.tag;
                    break;
                }
            }
        }
        if (focusedIndex != -1)
            break;
    }
    
    if (focusedIndex == -1)
        return;
    
    NSLog(@"focusedIndex = %d", (int)focusedIndex);
    [_tableChallenges scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:focusedIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

- (void)onDateChallengeTimer:(NSTimer *)timer
{
    NSLog(@"Timer fired....");
    
    PFQuery *queryChallenges1 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges1 whereKey:@"from_user" equalTo:[PFUser currentUser]];
    [queryChallenges1 whereKey:@"to_user" equalTo:_selectedUser];
    PFQuery *queryChallenges2 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges2 whereKey:@"from_user" equalTo:_selectedUser];
    [queryChallenges2 whereKey:@"to_user" equalTo:[PFUser currentUser]];
    PFQuery *queryChallenges = [PFQuery orQueryWithSubqueries:@[queryChallenges1, queryChallenges2]];
    [queryChallenges whereKey:@"challenge_type" equalTo:[NSNumber numberWithInt:DATE_CHALLENGE]];
    [queryChallenges whereKey:@"phase" notEqualTo:[NSNumber numberWithInt:CHALLENGE_SOLVED]];
    [queryChallenges whereKey:@"suggest_time" lessThanOrEqualTo:[NSDate date]];
    [queryChallenges includeKey:@"from_user"];
    [queryChallenges includeKey:@"to_user"];
    [queryChallenges findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil || objects == nil || objects.count <= 0)
            return;
        
        NSLog(@"Found date challenge(s) to unlock.");
        
        for (int i = 0; i < objects.count; i ++)
        {
            PFObject *challengeObject = [objects objectAtIndex:i];
            challengeObject[@"phase"] = [NSNumber numberWithInt:CHALLENGE_SOLVED];
            [challengeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFQuery *queryMessages = [PFQuery queryWithClassName:@"chat_history"];
                [queryMessages whereKey:@"challenge" equalTo:challengeObject];
                [queryMessages orderByAscending:@"updatedAt"];
                [queryMessages findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error == nil && objects != nil)
                    {
                        __block int updateCount = 0;
                        for (int j = 0; j < objects.count; j ++)
                        {
                            PFObject *messageObject = [objects objectAtIndex:j];
                            messageObject[@"challenge_solved"] = @YES;
                            [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                updateCount ++;
                                NSLog(@"Date challenge updated in timer .... %d", updateCount);
                                if (updateCount >= objects.count)
                                {
                                    NSLog(@"All date challenge updated in timer");
                                    
                                    PFUser *toUser = challengeObject[@"to_user"];
                                    if ([toUser.objectId isEqualToString:[PFUser currentUser].objectId])
                                    {
                                        NSString *strMessage = [NSString stringWithFormat:@"Date challenge to '%@' has been unlocked.", [Globals displayNameForUser:[PFUser currentUser]]];
                                        [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Remote_Notification object:nil userInfo:@{@"type":[NSNumber numberWithInt:NOTIFY_CHALLENGE_CHANGED], @"from_user":_selectedUser.objectId}];
                                    }
                                    else
                                    {
                                        NSString *strMessage = [NSString stringWithFormat:@"Date challenge from '%@' has been unlocked.", [Globals displayNameForUser:[PFUser currentUser]]];
                                        [AppDelegate sendPushMessageToUser:_selectedUser withMessage:strMessage withType:NOTIFY_CHALLENGE_CHANGED withCustomData:nil];
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Challenge_Changed object:nil];
                                    }
                                }
                            }];
                        }
                    }
                }];
            }];
        }
    }];
}

- (void)refreshAllChallenges
{
    PFQuery *queryChallenges1 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges1 whereKey:@"from_user" equalTo:_selectedUser];
    [queryChallenges1 whereKey:@"to_user" equalTo:[PFUser currentUser]];
    PFQuery *queryChallenges2 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges2 whereKey:@"from_user" equalTo:[PFUser currentUser]];
    [queryChallenges2 whereKey:@"to_user" equalTo:_selectedUser];
    
    PFQuery *queryChallenges = [PFQuery orQueryWithSubqueries:@[queryChallenges1, queryChallenges2]];
    [queryChallenges orderByDescending:@"updatedAt"];
    [queryChallenges includeKey:@"from_user"];
    [queryChallenges includeKey:@"to_user"];
    [queryChallenges findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error != nil ||
            objects == nil)
            return;
        arrayChallenges = objects;
        [_tableChallenges reloadData];
        if (arrayChallenges.count > 0)
            [_tableChallenges scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrayChallenges.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        if (_isShown)
            [self updateLastShownChallenge];
        
        [self updateUserScore];
    }];
}

- (void)updateLastShownChallenge
{
    if (arrayChallenges == nil ||
        arrayChallenges.count <= 0)
        return;
    
    PFObject *lastChallengeObject = nil;
    for (int i = 0; i < arrayChallenges.count; i ++)
    {
        PFObject *challengeObject = [arrayChallenges objectAtIndex:i];
        PFUser *toUser = challengeObject[@"to_user"];
        if ([toUser.objectId isEqualToString:[PFUser currentUser].objectId])
        {
            lastChallengeObject = challengeObject;
            break;
        }
    }
    if (lastChallengeObject == nil)
        return;
    
    PFQuery *queryShownChat = [PFQuery queryWithClassName:@"shown_chats"];
    [queryShownChat whereKey:@"from_user" equalTo:_selectedUser];
    [queryShownChat whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryShownChat findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *shownChatObject;
        if (error != nil ||
            objects == nil ||
            objects.count <= 0)
        {
            shownChatObject = [PFObject objectWithClassName:@"shown_chats"];
            shownChatObject[@"from_user"] = _selectedUser;
            shownChatObject[@"to_user"] = [PFUser currentUser];
            shownChatObject[@"shown_challenge"] = lastChallengeObject;
        }
        else
        {
            shownChatObject = [objects objectAtIndex:0];
            shownChatObject[@"shown_challenge"] = lastChallengeObject;
        }
        [shownChatObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSInteger relationIndex = [self findIndexOfUserInFriendRelationList:_selectedUser.objectId];
                if (relationIndex == -1)
                    return;
                FriendRelation *friendRelation = [[Globals arrayFriendRelations] objectAtIndex:relationIndex];
                NSString *relationId = friendRelation.relationId;
                
                NSMutableDictionary *dictionaryHistoryData = [Globals dictionaryHistoryData];
                HistoryData *historyData = [dictionaryHistoryData objectForKey:relationId];
                if (historyData == nil)
                    historyData = [[HistoryData alloc] init];
                historyData.lastShownChallenge = lastChallengeObject;
                [dictionaryHistoryData setObject:historyData forKey:friendRelation.relationId];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Self_History_Changed object:nil];
            }
        }];
    }];
}

- (NSInteger)findIndexOfUserInFriendRelationList:(NSString *)friendId
{
    NSMutableArray *arrayFriendRelations = [Globals arrayFriendRelations];
    if (arrayFriendRelations == nil)
        return -1;
    
    NSInteger index = -1;
    for (NSInteger i = 0; i < arrayFriendRelations.count; i ++)
    {
        FriendRelation *friendRelation = [arrayFriendRelations objectAtIndex:i];
        if ([friendRelation.friendUser.objectId isEqualToString:friendId])
        {
            index = i;
            break;
        }
    }
    return index;
}

- (void)updateUserScore
{
    NSLog(@"--------------------\nTrying to update score.");
    
    PFQuery *queryChallenges1 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges1 whereKey:@"from_user" equalTo:[PFUser currentUser]];
    [queryChallenges1 whereKey:@"from_scored" notEqualTo:@YES];
    PFQuery *queryChallenges2 = [PFQuery queryWithClassName:@"challenge_history"];
    [queryChallenges2 whereKey:@"to_user" equalTo:[PFUser currentUser]];
    [queryChallenges2 whereKey:@"to_scored" notEqualTo:@YES];
    PFQuery *queryChallenges = [PFQuery orQueryWithSubqueries:@[queryChallenges1, queryChallenges2]];
    [queryChallenges whereKey:@"phase" equalTo:[NSNumber numberWithInt:CHALLENGE_SOLVED]];
    [queryChallenges includeKey:@"from_user"];
    [queryChallenges includeKey:@"to_user"];
    [queryChallenges findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray *arrFoundChallenges = objects;
        if (error != nil ||
            arrFoundChallenges == nil ||
            arrFoundChallenges.count <= 0)
            return;
        
        NSLog(@"-------------------\nFound the challenges solved but not scored.  count = %d(%d)", (int)arrFoundChallenges.count, (int)objects.count);
        int increase = 0;
        for (int i = 0; i < arrFoundChallenges.count; i ++)
        {
            PFObject *challengeObject = [arrFoundChallenges objectAtIndex:i];
            PFUser *fromUser = challengeObject[@"from_user"];
            if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
                increase += 2;
            else
            {
                if ([challengeObject[@"force_solved"] boolValue] == YES)
                    increase += 5;
                else
                    increase += 3;
            }
        }
        NSLog(@"-----------------------\nScore to increase : %d", increase);
        PFUser *currentUser = [PFUser currentUser];
        int currentScore = [currentUser[@"scores"] intValue];
        currentUser[@"scores"] = [NSNumber numberWithInt:(currentScore + increase)];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil || !succeeded)
                return;
            for (int i = 0; i < arrFoundChallenges.count; i ++)
            {
                PFObject *challengeObject = [arrFoundChallenges objectAtIndex:i];
                PFUser *fromUser = challengeObject[@"from_user"];
                if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId])
                    challengeObject[@"from_scored"] = @YES;
                else
                    challengeObject[@"to_scored"] = @YES;
                [challengeObject saveInBackground];
            }
        }];
    }];
}

@end
