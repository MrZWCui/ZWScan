//
//  ZWScanViewController.m
//  ZWScan
//
//  Created by 崔先生的MacBook Pro on 2022/10/6.
//

#import "ZWScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ZWScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;//捕捉会话
@property (nonatomic, strong) AVCaptureDeviceInput *input;//输入流
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;//输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;//预览涂层

@end

@implementation ZWScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self startCapture];
}

- (void)dealloc {
    self.input = nil;
    self.metadataOutput = nil;
    self.session = nil;
    self.videoPreviewLayer = nil;
}

#pragma makr - 请求权限
- (BOOL)requestDeviceAuthorization{
    AVAuthorizationStatus deviceStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (deviceStatus == AVAuthorizationStatusRestricted ||
        deviceStatus == AVAuthorizationStatusDenied){
        NSLog(@"相机未授权");
        return NO;
    }
    NSLog(@"相机已授权");
    return YES;
}

- (void)startCapture {
    if (![self requestDeviceAuthorization]) {
        NSLog(@"没有访问相机权限！");
        return;
    }
    
//    [self.session beginConfiguration];
    //添加设备输入流到会话对象
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    //设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSArray *types = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode93Code];
        self.metadataOutput.metadataObjectTypes = types;
    }
    [self.session commitConfiguration];
    /*开始捕获数据和停止捕获。最好不要把它们放在主线程中使用。因为 startRunning 和 stopRunning 其实是一个 block，主线程调用可能会引起，UI卡顿。*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session startRunning];
        });

}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //扫描到的数据
    AVMetadataMachineReadableCodeObject *dataObject = (AVMetadataMachineReadableCodeObject *)[metadataObjects lastObject];
    /*识别到信息即停止识别*/
    if (dataObject) {
        NSLog(@"metadataObjects[last]==%@", dataObject.stringValue);
        [self stopCapture];
        [self addDescribeText:dataObject.stringValue];
        
    }
}

//停止扫描
- (void)stopCapture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session stopRunning];
        });
}

- (void)addDescribeText:(NSString *)str {
    UITextField *descText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    descText.center = self.view.center;
    descText.layer.cornerRadius = 20;
    descText.backgroundColor = [UIColor hexColor:@"#4c4c4c"];
    descText.textAlignment = NSTextAlignmentCenter;
    descText.textColor = [UIColor whiteColor];
    [descText setText:str];
    [self.view addSubview:descText];
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //设置会话采集率
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
    }
    return _session;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _metadataOutput;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        // 保持纵横比；填充层边界
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewLayer.frame = self.view.bounds;
    }
    return _videoPreviewLayer;
}


@end
