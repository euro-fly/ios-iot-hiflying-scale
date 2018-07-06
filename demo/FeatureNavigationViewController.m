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
    _myTimer = nil;
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
    [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"] state:NO];
    [defaults removeObjectForKey:@"macAddress"];
    [defaults removeObjectForKey:@"didSetup"];
    [defaults removeObjectForKey:@"secretMode"];
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"init"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) toggleSecretMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [_secretModeSwitch setOn:NO];
    [TCPHelper DeviceSecretMode:[defaults stringForKey:@"macAddress"] state:[_secretModeSwitch isOn]];
    [defaults setObject:[NSNumber numberWithBool:[_secretModeSwitch isOn]] forKey:@"secretMode"];
    [defaults synchronize];
}
                                
- (IBAction)secretModeSwitchPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([_secretModeSwitch isOn]) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                         target:self
                                        selector:@selector(toggleSecretMode)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        if (_myTimer != nil) {
            [_myTimer invalidate];
            _myTimer = nil;
        }
    }
    [TCPHelper DeviceSecretMode:[defaults stringForKey:@"macAddress"] state:[_secretModeSwitch isOn]];
    [defaults setObject:[NSNumber numberWithBool:[_secretModeSwitch isOn]] forKey:@"secretMode"];
    [defaults synchronize];
}
@end

