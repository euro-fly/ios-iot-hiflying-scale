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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"macAddress"] == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(qrCodeFound:)
                                                     name:@"macAddress"
                                                   object:nil];
    }
    else { // if we are already bound... we can just load into the navigation controller.
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"navigationRoot"];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:vc animated:YES completion:NULL];
    }
}

- (void) qrCodeFound:(NSNotification *) notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TCPHelper ConnectToDevice:[defaults stringForKey:@"macAddress"]];
}

- (IBAction)bindButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowCamera" sender:self];
}

@end
