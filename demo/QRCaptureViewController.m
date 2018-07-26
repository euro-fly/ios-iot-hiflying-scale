//
//  QRCaptureViewController.m
//  Demo
//
//  Created by Jacob on 2018/07/04.
//  Copyright © 2018 Peter. All rights reserved.
//

#import "QRCaptureViewController.h"

@interface QRCaptureViewController() {
    
}
@property (nonatomic) BOOL isReading;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation QRCaptureViewController

- (IBAction)cancelButtonPressed:(id)sender {
    [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"macAddress"
     object:[[NSNumber alloc] initWithBool:NO]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isReading = NO;
    _captureSession = nil;
    [self startReading];
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
    UIImage *img = [UIImage imageNamed:@"reticle.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = _viewPreview.layer.bounds;
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    [_viewPreview addSubview:imageView];
    [self.view bringSubviewToFront:_cancelButton];
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
            NSString *qrValue = [metadataObj stringValue];
            BOOL validData;
            NSLog(@"[length] %lu", (unsigned long)[qrValue length]);
            if ([qrValue length] < 31 || ![[qrValue substringWithRange:NSMakeRange(0, 6)] isEqualToString:@"S1MAC:"]) {
                validData = NO;
            }
            else {
                NSString *ssid = [qrValue substringWithRange:NSMakeRange(6, 12)];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:ssid forKey:@"macAddress"];
                [defaults synchronize];
                validData = YES;
            }
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"macAddress"
             object:[[NSNumber alloc] initWithBool:validData]];
            
        }
    }
}

@end


