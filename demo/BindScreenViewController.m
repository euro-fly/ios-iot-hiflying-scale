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
    if ([defaults stringForKey:@"macAddress"] == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(qrCodeFound:)
                                                     name:@"macAddress"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(serverConnectEvent:)
                                                     name:@"0x12"
                                                   object:nil];
    }
    else { // if we are already bound... we can just load into the navigation controller.
        NSLog(@"[LOG] Already have a mac address.");
        [self performSegueWithIdentifier:@"GoMainMenu" sender:self];
    }
}

- (void) loadMainMenu {
    
}

- (void) qrCodeFound:(NSNotification *) notification {
    [self.modalViewController dismissViewControllerAnimated:YES completion:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"]];
    NSLog(@"[LOG] QR Code Found!!");
}

- (void) serverConnectEvent:(NSNotification *) notification {
    NSNumber *result = [notification object];
    if (result.boolValue) {
        [self performSegueWithIdentifier:@"ShowSuccessScreen" sender:self];
    }
    else {
        
    }
}

- (IBAction)bindButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowCamera" sender:self];
}

@end
