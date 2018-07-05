//
//  BindSuccessViewController.m
//  Demo
//
//  Created by Jacob on 2018/07/05.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindSuccessViewController.h"

@implementation BindSuccessViewController

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"TRUE" forKey:@"didSetup"];
}

- (IBAction)skipButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"GoToMainMenuFromSuccessScreen" sender:self];
}

- (IBAction)wifiConfigButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ConfigWifiFromSuccessScreen" sender:self];
}
@end

