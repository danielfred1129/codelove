//
//  PhotoPickerViewController.h
//  Chatlenge
//
//  Created by lion on 6/17/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPickerViewController;

@protocol PhotoPickerControllerDelegate <NSObject>

- (void)photoPickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)photoPickerControllerDidCancel:(PhotoPickerViewController *)picker;

@end

@interface PhotoPickerViewController : UIViewController <UIImagePickerControllerDelegate,
                                                         UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnLibrary;
@property (assign, nonatomic) id<PhotoPickerControllerDelegate> delegate;

- (IBAction)onCamera:(id)sender;
- (IBAction)onLibrary:(id)sender;
- (IBAction)onBack:(id)sender;

- (BOOL) prefersStatusBarHidden;

@end
