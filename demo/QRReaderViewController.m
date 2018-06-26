//
//  ViewController.m
//  qrcode-test1
//
//  Created by Jacob on 2018/06/26.
//  Copyright © 2018 Jacob. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) BOOL isReading;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isReading = NO;
    _captureSession = nil;
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
            NSLog(@"%@", ssid); // we only want the twelve characters starting from index 6 bc that's our mac address
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_buttonStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonStartAction:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            [_buttonStart setTitle:@"Stop Scan" forState:UIControlStateNormal];
        }
    }
    else {
        [self stopReading];
        [_buttonStart setTitle:@"Start!" forState:UIControlStateNormal];
    }
    _isReading = !_isReading;
}

@end
