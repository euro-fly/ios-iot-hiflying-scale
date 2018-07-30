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

-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
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
    _timeRemaining = @"05:00";
}

-(void)showCountdown{
    if (_countdownPopup == nil) {
        _countdownPopup = [[UIAlertView alloc]initWithTitle:@"秘密モード時間残り" message:_timeRemaining delegate:self cancelButtonTitle:@"戻る" otherButtonTitles:@"停止", nil];
    }
    [_countdownPopup show];
}

-(NSString *)tickTimer {
    float counter = _myTimer.fireDate.timeIntervalSinceNow;
    int minutes = ((int) counter % 3600) / 60;
    int seconds = ((int) counter % 3600) % 60;
    
    _timeRemaining = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    _countdownPopup.message = _timeRemaining;
    return _timeRemaining;
}
                                
- (IBAction)secretModeInfoButtonPressed:(id)sender {
    [self showAlertWithMsg:@"秘密モードはみんなに内緒のモードである。" title:@"秘密モードについて"];
}

- (void)startTimer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"secretMode"];
    _timeRemaining = @"05:00";
    [self showCountdown];
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:300.0
                                                target:self
                                              selector:@selector(toggleSecretMode)
                                              userInfo:nil
                                               repeats:NO]; // primary timer to show
    [self tickTimer];
    _secondTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self                                                  selector:@selector(tickTimer)
                                                  userInfo:nil
                                                   repeats:YES]; // secondary timer to update our countdown popup
}

- (IBAction)secretModeButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"timer...");
    if ([defaults boolForKey:@"secretMode"] != nil) {
        NSLog(@"boolean exists...");
        if ([defaults boolForKey:@"secretMode"] == YES && _myTimer != nil && _secondTimer != nil) {
            NSLog(@"boolean is true.");
            [self showCountdown];
        }
        else {
            [self startTimer];
        }
    }
    else {
        [self startTimer];
    }
}

@end

