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
- (IBAction)wifiConfigButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToWifiConfig" sender:self];
}
- (IBAction)readDataButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"NavigateToReadData" sender:self];
}
- (IBAction)unbindButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper KillData:[defaults stringForKey:@"macAddress"]];
    [defaults removeObjectForKey:@"macAddress"];
    [defaults removeObjectForKey:@"didSetup"];
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"init"];
    [self presentViewController:vc animated:YES completion:nil];
}
@end

