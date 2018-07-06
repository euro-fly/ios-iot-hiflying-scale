//
//  FeatureNavigationViewController.m
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeatureNavigationViewController.h"
#import "Demo-Swift.h"

@implementation FeatureNavigationViewController

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _userID.text = [defaults stringForKey:@"userID"];
    if ([defaults objectForKey:@"secretMode"] != nil) {
        NSNumber *initialState = [defaults objectForKey:@"secretMode"];
        [_secretModeSwitch setOn:[initialState boolValue]];
    }
    [_secretModeSwitch setOn:NO]; // by default, secret mode should be disabled...
}
- (IBAction)wifiConfigButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToWifiConfig" sender:self];
}
- (IBAction)readDataButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToReadData" sender:self];
}
- (IBAction)unbindButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[TCPHelper KillData:[defaults stringForKey:@"macAddress"]];
    [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"] state:NO];
    [defaults removeObjectForKey:@"macAddress"];
    [defaults removeObjectForKey:@"didSetup"];
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"init"];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)secretModeSwitchPressed:(id)sender {
    // [secretModeSwitch isOn]
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper DeviceSecretMode:[defaults stringForKey:@"macAddress"] state:[_secretModeSwitch isOn]];
    [defaults setObject:[NSNumber numberWithBool:[_secretModeSwitch isOn]] forKey:@"secretMode"];
    [defaults synchronize];
    
}
@end

