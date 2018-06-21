//
//  ViewController.h
//  Demo
//
//  Created by Peter on 15/11/26.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtSSID;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UIButton *butConnect;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;

- (IBAction)butPressed:(id)sender;
- (IBAction)swPressed:(id)sender;

@end

