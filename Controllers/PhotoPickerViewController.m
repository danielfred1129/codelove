//
//  PhotoPickerViewController.m
//  Chatlenge
//
//  Created by lion on 6/17/14.
//  Copyright (c) 2014 Daniel Clarke. All rights reserved.
//

#import "PhotoPickerViewController.h"

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _delegate = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [_btnCamera setEnabled:YES];
    else
        [_btnCamera setEnabled:NO];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [_btnLibrary setEnabled:YES];
    else
        [_btnLibrary setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCamera:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

- (IBAction)onLibrary:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

- (IBAction)onBack:(id)sender
{
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)])
        [_delegate photoPickerControllerDidCancel:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
    
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(photoPickerController:didFinishPickingMediaWithInfo:)])
        [_delegate photoPickerController:self didFinishPickingMediaWithInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
    
    if (_delegate != nil &&
        [_delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)])
        [_delegate photoPickerControllerDidCancel:self];
}

@end
