//
//  BindScreen.h
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BindScreenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
- (IBAction)bindButtonPressed:(id)sender;
- (void) qrCodeFound:(NSNotification *) notification;
@end
