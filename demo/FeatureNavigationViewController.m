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
    [_secretModeSwitch setOn:NO]; // by default, secret mode should be disabled...
}
- (IBAction)wifiConfigButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToWifiConfig" sender:self];
}
- (IBAction)readDataButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToReadData" sender:self];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        
    }else{
        NSLog(@"Killing timer.");
        [self toggleSecretMode];
    }
}


- (IBAction)unbindButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"] state:NO];
    [defaults removeObjectForKey:@"macAddress"];
    [defaults removeObjectForKey:@"didSetup"];
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"init"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) toggleSecretMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"secretMode"];
    if (_myTimer != nil) {
        [_myTimer invalidate];
        [_secondTimer invalidate];
        _myTimer = nil;
        _secondTimer = nil;
    }
}

-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
    if (_countdownPopup == nil) {
        _countdownPopup = [[UIAlertView alloc]initWithTitle:title message:[self tickTimer] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    }
    [_countdownPopup show];
}

-(NSString *)tickTimer {
    float counter = _myTimer.fireDate.timeIntervalSinceNow;
    int minutes = ((int) counter % 3600) / 60;
    int seconds = ((int) counter % 3600) % 60;
    NSLog(@"%f %d %d", counter, minutes, seconds);
    _timeRemaining = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    return _timeRemaining;
}
                                
- (IBAction)secretModeButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"timer...");
    if ([defaults boolForKey:@"secretMode"] != nil) {
        NSLog(@"boolean exists...");
        if ([defaults boolForKey:@"secretMode"] == YES) {
            NSLog(@"boolean is true.");
            [self showAlertWithMsg:@"Time Remaining" title:@"時間残り"];
        }
        else {
            [defaults setBool:YES forKey:@"secretMode"];
            _timeRemaining = @"05:00";
            _myTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                        target:self
                                                      selector:@selector(toggleSecretMode)
                                                      userInfo:nil
                                                       repeats:NO];
            
            _secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(tickTimer)
                                                          userInfo:nil
                                                           repeats:YES];
            [self showAlertWithMsg:@"Time Remaining" title:@"時間残り"];
        }
    }
    else {
        [defaults setBool:YES forKey:@"secretMode"];
        _timeRemaining = @"05:00";
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                    target:self
                                                  selector:@selector(toggleSecretMode)
                                                  userInfo:nil
                                                   repeats:NO];
        
        _secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(tickTimer)
                                                      userInfo:nil
                                                       repeats:YES];
        [self showAlertWithMsg:@"Time Remaining" title:@"時間残り"];
    }
}

@end

