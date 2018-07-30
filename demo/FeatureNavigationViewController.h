//
//  FeatureNavigationViewController.h
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface FeatureNavigationViewController : UIViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userID;
@property (weak, nonatomic) IBOutlet UIButton *wifiConfigButton;
- (IBAction)wifiConfigButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *secretModeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *secretModeButton;
@property (weak, nonatomic) IBOutlet UIButton *secretModeInfoButton;
- (IBAction)secretModeInfoButtonPressed:(id)sender;
- (IBAction)secretModeButtonPressed:(id)sender;
- (IBAction)secretModeSwitchPressed:(id)sender;
@property (weak, nonatomic) NSTimer *myTimer;
@property (weak, nonatomic) NSTimer *secondTimer;
- (void)toggleSecretMode;
@property (weak, nonatomic) IBOutlet UIButton *readDataButton;
- (IBAction)readDataButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *unbindButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSelector;
@property (strong, nonatomic) UIAlertView *countdownPopup;
@property (weak, nonatomic) NSString* timeRemaining;
- (IBAction)unitSelectorPressed:(id)sender;
- (IBAction)unbindButtonPressed:(id)sender;
@end
