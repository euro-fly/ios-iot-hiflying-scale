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


@interface ViewController ()
{
    HFSmartLink * smtlk;
    BOOL isconnecting;
    
}
@property (nonatomic) NSString* scaleMacAddress;
@property (nonatomic) BOOL isReading;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _isReading = NO;
    _captureSession = nil;
    _scaleMacAddress = nil;
    // Do any additional setup after loading the view, typically from a nib.
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    smtlk.waitTimers = 30;
    isconnecting=false;
    
    self.progress.progress = 0.0;
    self.switcher.on = smtlk.isConfigOneDevice;
    
    [self showWifiSsid];
    self.txtPwd.text = [self getspwdByssid:self.txtSSID.text];
    _txtPwd.delegate=self;
    _txtSSID.delegate=self;
}

- (BOOL)startReading {
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    [_captureSession startRunning];
    return YES;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *ssid = [[metadataObj stringValue] substringWithRange:NSMakeRange(6, 12)];
            _scaleMacAddress = ssid;
            _myLabel.text = ssid;
            NSLog(@"%@", ssid); // we only want the twelve characters starting from index 6 bc that's our mac address
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_captureButton
             performSelectorOnMainThread:@selector(setTitle:) withObject:@"Capture QR Code" waitUntilDone:NO];
            _isReading = NO;
        }
    }
}



- (IBAction)connectButtonPressed:(id)sender {
    if (_scaleMacAddress != nil) {
        [TCPHelper ConnectToDevice:_scaleMacAddress];
    }
    
}

- (IBAction)readButtonPressed:(id)sender {
    if (_scaleMacAddress != nil) {
        [TCPHelper ReadData:_scaleMacAddress];
    }
}

- (IBAction)killButtonPressed:(id)sender {
    if (_scaleMacAddress != nil) {
        [TCPHelper KillData:_scaleMacAddress];
    }
}

- (IBAction)captureButtonPressed:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            [_captureButton setTitle:@"Capture QR Code" forState:UIControlStateNormal];
        }
    }
    else {
        [self stopReading];
    }
    _isReading = !_isReading;
}

- (IBAction)butPressed:(id)sender {
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
            }else{
                [self showAlertWithMsg:stopMsg title:@"error"];
            }
        }];
    }
}

- (IBAction)swPressed:(id)sender {
    if(self.switcher.on){
        smtlk.isConfigOneDevice = true;
    }else{
        smtlk.isConfigOneDevice = false;
    }
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
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
