//
//  BindSuccessViewController.h
//  demo
//
//  Created by Jacob on 2018/07/05.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BindSuccessViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *wifiConfigButton;
- (IBAction)skipButtonPressed:(id)sender;
- (IBAction)wifiConfigButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@end
