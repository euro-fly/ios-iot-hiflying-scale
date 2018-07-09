//
//  QRCaptureViewController.h
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface QRCaptureViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@end
