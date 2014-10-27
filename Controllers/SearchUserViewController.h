//
//  SearchViewController.h
//  Chatlenge
//
//  Created by lion on 7/14/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserViewController : UIViewController <UISearchBarDelegate,
                                                        UITableViewDataSource,
                                                        UITableViewDelegate>
{
    NSArray *arraySearchedUsers;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableUsers;

- (IBAction)onBack:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
