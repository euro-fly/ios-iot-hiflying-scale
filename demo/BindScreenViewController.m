//
//  BindScreen.m
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindScreenViewController.h"
#import "Demo-Swift.h"
@implementation BindScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"userID"] == nil) {
        NSString *uuid = [[NSUUID UUID] UUIDString]; // we generate a UUID which makes 秘密モード　testable.
        [defaults setObject:uuid forKey:@"userID"];
        [defaults synchronize];
    }
    NSLog(@"USER ID: %@", [defaults objectForKey:@"userID"]);
    if ([defaults stringForKey:@"macAddress"] == nil || [defaults stringForKey:@"didSetup"] == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(qrCodeFound:)
                                                     name:@"macAddress"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverConnectEvent:)
                                                     name:@"0x12"
                                                   object:nil];
    }
    else if ([defaults stringForKey:@"didSetup"] != nil) { // if we are already bound... we can just load into the navigation controller.
        [self performSegueWithIdentifier:@"GoMainMenu" sender:self];
    }
}

- (void) loadMainMenu {
    
}

- (void) qrCodeFound:(NSNotification *) notification {
    NSNumber *result = [notification object];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        if (result.boolValue) {
            NSLog(@"[LOG] QR Code Found!!");
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"] state:YES];
        }
        else {
            NSLog(@"[LOG] Failed to get QR code");
        }
    }];
    
    
}

- (void) serverConnectEvent:(NSNotification *) notification {
    NSNumber *result = [notification object];
    if (result.boolValue) {
        [self performSegueWithIdentifier:@"ShowSuccessScreen" sender:self];
    }
    else {
        NSLog(@"We couldn't connect to the network. Try again...");
    }
}

- (IBAction)bindButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowCamera" sender:self];
}

@end
