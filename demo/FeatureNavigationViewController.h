//
//  FeatureNavigationViewController.h
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface FeatureNavigationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UIButton *wifiConfigButton;
- (IBAction)wifiConfigButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *secretModeSwitch;
- (IBAction)secretModeSwitchPressed:(id)sender;
@property (weak, nonatomic) NSTimer *myTimer;
- (void)toggleSecretMode;
@property (weak, nonatomic) IBOutlet UIButton *readDataButton;
- (IBAction)readDataButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *unbindButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSelector;
- (IBAction)unitSelectorPressed:(id)sender;
- (IBAction)unbindButtonPressed:(id)sender;
@end
