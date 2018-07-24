//
//  ViewController.m
//  Demo
//
//  Created by Peter on 15/11/26.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "ViewController.h"
#import "Demo-Swift.h"
//#import "smartlinklib_7x.h"
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import "HTBodyfat.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#if __has_feature(objc_arc)
#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define DLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

@interface ViewController ()
{
    HFSmartLink * smtlk;
    BOOL isconnecting;
    
}
@property (nonatomic) NSString* scaleMacAddress;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _scaleMacAddress = [defaults stringForKey:@"macAddress"];
    _myLabel.text = _scaleMacAddress;
    
    // Do any additional setup after loading the view, typically from a nib.
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = false;
    smtlk.waitTimers = 30;
    isconnecting=false;
    
    self.progress.progress = 0.0;
    self.switcher.on = true;
    
    [self showWifiSsid];
    self.txtPwd.text = [self getspwdByssid:self.txtSSID.text];
    _txtPwd.delegate=self;
    _txtSSID.delegate=self;
}

- (IBAction)butPressed:(id)sender {
    [TCPHelper KillData:_scaleMacAddress]; // fire netclear (0x14) before connecting...
    NSString * ssidStr= self.txtSSID.text;
    NSString * pswdStr = self.txtPwd.text;
    
    NSLog(@"%@======%@", ssidStr, pswdStr);
    
    [self savePswd];
    self.progress.progress = 0.0;
    if(!isconnecting){
        isconnecting = true;
        [smtlk startWithSSID:ssidStr Key:pswdStr withV3x:true
                processblock: ^(NSInteger pro) {
                    self.progress.progress = (float)(pro)/100.0;
                } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                    [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
                    [self doTransition];
                } failBlock:^(NSString *failmsg) {
                    [self  showAlertWithMsg:failmsg title:@"error"];
                } endBlock:^(NSDictionary *deviceDic) {
                    isconnecting  = false;
                    [self.butConnect setTitle:@"connect" forState:UIControlStateNormal];
                }];
        [self.butConnect setTitle:@"connecting" forState:UIControlStateNormal];
    }else{
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            if(isOk){
                isconnecting  = false;
                [self.butConnect setTitle:@"1connect" forState:UIControlStateNormal];
                [self showAlertWithMsg:stopMsg title:@"OK"];
                [self doTransition];
            }else{
                [self showAlertWithMsg:stopMsg title:@"error"];
            }
        }];
    }
}

-(void)doTransition {
    if (self.navigationController == nil) {
        [self performSegueWithIdentifier:@"GoToMainMenuFromWifiConfig" sender:self];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)swPressed:(id)sender {
    smtlk.isConfigOneDevice = [self.switcher isOn];
}

-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    [alert show];
}

-(void)savePswd{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.txtPwd.text forKey:self.txtSSID.text];
}
-(NSString *)getspwdByssid:(NSString * )mssid{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:mssid];
}

- (void)showWifiSsid
{
    BOOL wifiOK= FALSE;
    NSDictionary *ifs;
    NSString *ssid;
    UIAlertView *alert;
    if (!wifiOK)
    {
        ifs = [self fetchSSIDInfo];
        ssid = [ifs objectForKey:@"SSID"];
        if (ssid!= nil)
        {
            wifiOK= TRUE;
            self.txtSSID.text = ssid;
        }
        else
        {
            alert= [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请连接Wi-Fi"] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            alert.delegate=self;
            [alert show];
        }
    }
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    DLog(@"[log] %@", ifs[0]);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        DLog(@"[log] %@", info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
