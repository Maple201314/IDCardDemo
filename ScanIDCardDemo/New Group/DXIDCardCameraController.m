//
//  DXIDCardCameraController.m
//  ScanIDCardDemo
//
//  Created by William on 2019/1/4.
//  Copyright © 2019 William. All rights reserved.
//

#import "DXIDCardCameraController.h"
#import <AVKit/AVKit.h>

@interface DXIDCardCameraController ()

@property(nonatomic,assign) DXIDCardType type;
@property(nonatomic,assign) BOOL isFlashOn;
@property(nonatomic,strong) UIImageView* imageView;
@property(nonatomic,strong) UIImage* image;

@property(nonatomic,strong)  AVCaptureDevice* device ;
@property(nonatomic,strong)  AVCaptureStillImageOutput* imageOutput;
@property(nonatomic,strong)  AVCaptureSession* session;
@property(nonatomic,strong)  AVCaptureVideoPreviewLayer* previewLayer;
@property(nonatomic,strong)  DXIDCardFloatingView* floatingView;
@property(nonatomic,strong)  UIButton* photoButton;
@property(nonatomic,strong)  UIButton* cancleButton;
@property(nonatomic,strong)  UIButton* flashButton;
@property(nonatomic,strong)  UIView* bottomView;
@property(nonatomic,strong)  NSBundle* resouceBundle;

@end

@implementation DXIDCardCameraController

- (instancetype)initWithType:(DXIDCardType)type {
    self = [super init];
    if (self) {
        self.type = type;
        _isFlashOn = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    _session = [[AVCaptureSession alloc] init];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.frame = UIScreen.mainScreen.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _floatingView = [[DXIDCardFloatingView alloc] init];
    [_floatingView initWithType:self.type];
    
    _resouceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"DXIDCardCamera" ofType:@"bundle"]];

    CGFloat kScreenH = UIScreen.mainScreen.bounds.size.height;
    CGFloat kScreenW = UIScreen.mainScreen.bounds.size.width;
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setImage:[UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"photo@2x" ofType:@"png"]] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"photo@3x" ofType:@"png"]] forState:UIControlStateNormal];
    [_photoButton addTarget:self action:@selector(shutterCamera:) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.frame = CGRectMake( (kScreenW-60)/2, kScreenH-60-40, 60, 60);
    
    _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancleButton setImage:[UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"closeButton" ofType:@"png"]] forState:UIControlStateNormal];
    [_cancleButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancleButton.frame = CGRectMake( 32, kScreenH-45-40, 45, 45);
    
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashButton setImage:[UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"cameraFlash" ofType:@"png"]] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
    _flashButton.frame = CGRectMake(kScreenW-45-32, kScreenH-45-40, 45, 45);
    
    _bottomView = [UIView new];
    _bottomView.backgroundColor = UIColor.blackColor;
    _bottomView.hidden = true;
    _bottomView.frame = CGRectMake(0, kScreenH-64, kScreenW, 64);
   
    /**重拍**/
    UIButton* againBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [againBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [againBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [againBtn addTarget:self action:@selector(takePhotoAgain:) forControlEvents:UIControlEventTouchUpInside];
    againBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    againBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    againBtn.frame = CGRectMake(12, 0, 64, 64);
    againBtn.transform = CGAffineTransformMakeRotation(M_PI_2);;
    [_bottomView addSubview:againBtn];
    /**使用照片**/
    UIButton* useBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [useBtn setTitle:@"使用" forState:UIControlStateNormal];
    [useBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [useBtn addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchUpInside];
    useBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    useBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    useBtn.frame = CGRectMake(kScreenW-100, 0, 100, 64);
    useBtn.transform = CGAffineTransformMakeRotation(M_PI_2);;
    [_bottomView addSubview:useBtn];
    
    
    if([self isCanUseCamera] == true){
        [self setupCamera];
        [self configureUI];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGPoint point = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    [self focusAtPoint:point];
}
- (BOOL)isCanUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:@"请到设置中去允许应用访问您的相机: 设置-隐私-相机" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不需要" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSURL *setUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            UIApplication *application = UIApplication.sharedApplication;
            if([application canOpenURL:setUrl]){
                [application openURL:setUrl];
            }
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        UIViewController* root = UIApplication.sharedApplication.keyWindow.rootViewController;
        [root presentViewController:alert animated:true completion:nil];
        return false;
    }
    return true;
}
- (void)setupCamera{
    if([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]){
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if (_device!=nil) {
        [_device lockForConfiguration:nil];
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:nil];
        if([_session canAddInput:input]){
            [_session addInput:input];
        }
        [_device unlockForConfiguration];
        if ([_session canAddOutput:_imageOutput]) {
            [_session addOutput:_imageOutput];
        }
        // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
        [self.view.layer addSublayer:_previewLayer];
        [_session startRunning];
        [_device lockForConfiguration:nil];
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            _device.flashMode = AVCaptureFlashModeAuto;
        }
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            _device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        }
        [_device unlockForConfiguration];
        [self.view addSubview:_floatingView];
    }
    
}
- (void)configureUI{
    [self.view addSubview:_photoButton];
    [self.view addSubview:_cancleButton];
    [self.view addSubview:_flashButton];
    [self.view addSubview:_bottomView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(focusGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    NSNotificationCenter* kCenter = NSNotificationCenter.defaultCenter;
    [kCenter addObserver:self selector:@selector(subjectAreaDidChange:) name: AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}
- (void)focusAtPoint:(CGPoint)point{
    //CGSize size = self.view.bounds.size;
    //CGPoint focusPoint = CGPointMake(point.y/size.height, 1-point.x/size.width);
    //focusPoint should in the center of the screen
    if(_device != nil){
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [_device lockForConfiguration:nil];
        if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            _device.focusPointOfInterest = CGPointMake(0.5, 0.5);
            _device.focusMode = AVCaptureFocusModeAutoFocus;
        }
        if ([_device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            _device.exposurePointOfInterest = CGPointMake(0.5, 0.5);
            _device.exposureMode = AVCaptureExposureModeAutoExpose;
        }
        [_device unlockForConfiguration];
    }
    
}
- (void)shutterCamera:(UIButton*)button {
    __weak typeof(self) weakSelf = self;
    AVCaptureConnection* videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer,NSError * _Nullable error) {
        if(imageDataSampleBuffer != nil) {
            NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer  ];
            UIImage* img = [[UIImage alloc] initWithData:imageData];
            UIImage* newImg = [weakSelf cropImageToCGRect:weakSelf.floatingView.IDCardWindowLayer.bounds from:img];
            //roate the image
            weakSelf.image = [UIImage imageWithCGImage:newImg.CGImage scale:1.0 orientation:UIImageOrientationUp];
            [weakSelf.session stopRunning];
            weakSelf.imageView = [[UIImageView alloc] initWithFrame:weakSelf.floatingView.IDCardWindowLayer.frame];
            [weakSelf.view insertSubview:weakSelf.imageView belowSubview:button];
            weakSelf.imageView.layer.masksToBounds = true;
            weakSelf.imageView.layer.cornerRadius = 15;
            weakSelf.imageView.image = [UIImage imageWithCGImage:newImg.CGImage scale:1.0 orientation:UIImageOrientationRight];
            //weakSelf.imageView.contentMode = UIViewContentModeTopLeft;
            weakSelf.imageView.layer.borderColor = UIColor.whiteColor.CGColor;
            weakSelf.imageView.layer.borderWidth = 2;
            weakSelf.cancleButton.hidden = true;
            weakSelf.flashButton.hidden = true;
            weakSelf.photoButton.hidden = true;
            weakSelf.bottomView.hidden = false;
            weakSelf.floatingView.textLabel.hidden = true;
        }
    }];
}

- (void)cancleButtonAction:(UIButton*)button {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)flashOn:(UIButton*)button {
    if (nil == _device) {
        return;
    }
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if(self.isFlashOn == false){
            _device.torchMode = AVCaptureTorchModeOn;
            _isFlashOn = true;
        }else{
            _device.torchMode = AVCaptureTorchModeOff;
            _isFlashOn = false;
        }
        [_device unlockForConfiguration];
    }
}
- (void)takePhotoAgain:(UIButton*)button {
    [self.session startRunning];
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    self.cancleButton.hidden = false;
    self.flashButton.hidden = false;
    self.photoButton.hidden = false;
    self.bottomView.hidden = true;
    self.floatingView.textLabel.hidden = false;

}
- (void)usePhoto:(UIButton*)button {
    if(nil != self.delegate){
        [self.delegate cameraShootWithImage:self.image type:_type];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}
// 点击聚焦

- (void)focusGesture:(UITapGestureRecognizer*)gesture {
    CGPoint point  = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)subjectAreaDidChange:(NSNotification*)notification {
    //先进行判断是否支持控制对焦
    if(_device != nil && _device.isFocusPointOfInterestSupported && [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [_device lockForConfiguration:nil];
        _device.focusMode = AVCaptureFocusModeAutoFocus;
        CGRect bounds = UIScreen.mainScreen.bounds;
        CGPoint point = CGPointMake(bounds.size.width/2, bounds.size.height/2);
        [self focusAtPoint:point];
        [_device unlockForConfiguration];
    }
}

-(UIImage*) cropImageToCGRect:(CGRect)rect from:(UIImage*)oriImage {
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    
    CGFloat imageWidth  = CGImageGetWidth(oriImage.CGImage);
    CGFloat imageHeight = CGImageGetHeight(oriImage.CGImage);
    
    CGFloat widthScale  = imageWidth / screenHeight;
    CGFloat heightScale = imageHeight / screenWidth;
    
    //其实是横屏的
    CGFloat originWidth   = rect.size.width;
    CGFloat originHeight  = rect.size.height;
    NSLog(@"屏幕大小:%@",NSStringFromCGRect(UIScreen.mainScreen.bounds));
    NSLog(@"相框大小:%@",NSStringFromCGRect(rect));

    CGFloat x = (screenHeight - originHeight) * 0.5 * widthScale;
    CGFloat y = (screenWidth - originWidth) * 0.5 * heightScale;
    CGFloat height = originHeight * heightScale;
    CGFloat width  = height * originWidth / originHeight;
    CGRect current = CGRectMake(x, y, height, width);

    NSLog(@"裁剪大小:%@",NSStringFromCGRect(current));

    CGImageRef subImageRef = CGImageCreateWithImageInRect(oriImage.CGImage, current);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}
- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return false;
}
- (BOOL)shouldAutorotate {
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}



@end
