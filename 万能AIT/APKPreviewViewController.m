//
//  APKPreviewViewController.m
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKPreviewViewController.h"
#import "APKDVR.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKDVRCommandFactory.h"
#import "APKRealTimeViewingController.h"
#import "APKLockRemainingTimeRecorder.h"
#import "APKDVRFilesViewController.h"
#import <Photos/Photos.h>

@interface APKPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIView *disconnectView;
@property (weak, nonatomic) IBOutlet UILabel *disconnectLabel;
@property (weak, nonatomic) IBOutlet UIButton *captureButton2;
@property (weak, nonatomic) IBOutlet UIButton *videocamButton;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIView *xiongfengComponentsView;
@property (weak, nonatomic) IBOutlet UILabel *lockRemainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *functionToolView;
@property (strong,nonatomic) APKRealTimeViewingController *realTimeViewing;
@property (assign,nonatomic) CGRect playerViewFrame1;//竖屏frame
@property (assign,nonatomic) CGRect playerViewFrame2;//横屏frame
@property (assign,nonatomic) CGRect fullScreenButtonFrame1;//竖屏frame
@property (assign,nonatomic) CGRect fullScreenButtonFrame2;//横屏frame
@property (assign,nonatomic) CGRect captureButtonFrame1;//竖屏frame
@property (assign,nonatomic) CGRect captureButtonFrame2;//横屏frame
@property (assign,nonatomic) CGRect xiongfengComponentsViewFrame1;//
@property (assign,nonatomic) CGRect captureButton2Frame1;//
@property (assign,nonatomic) CGRect videocamButtonFrame1;//
@property (assign,nonatomic) CGRect lockButtonFrame1;//
@property (assign,nonatomic) CGRect xiongfengComponentsViewFrame2;//
@property (assign,nonatomic) CGRect captureButton2Frame2;//
@property (assign,nonatomic) CGRect videocamButtonFrame2;//
@property (assign,nonatomic) CGRect lockButtonFrame2;//
@property (assign,nonatomic) BOOL isFullScreenMode;
@property (assign,nonatomic) BOOL isGettingRTSPUrl;
@property (assign,nonatomic) BOOL isRecording;
@property (strong,nonatomic) APKLockRemainingTimeRecorder *lockRemainingTimeRecorder;
@property (nonatomic,retain) UILabel *titleL;
@end

@implementation APKPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationItem.title = NSLocalizedString(@"Mibo Car", nil);
    self.disconnectLabel.text = NSLocalizedString(@"未连接摄像机提示信息", nil);
    
    [self setupFrames];
    self.playerView.frame = self.playerViewFrame1;
    self.fullScreenButton.frame = self.fullScreenButtonFrame1;
    self.captureButton.frame = self.captureButtonFrame1;
    self.xiongfengComponentsView.frame = self.xiongfengComponentsViewFrame1;
    self.captureButton2.frame = self.captureButton2Frame1;
    self.videocamButton.frame = self.videocamButtonFrame1;
    self.lockButton.frame = self.lockButtonFrame1;
    self.lockRemainingTimeLabel.frame = self.lockButtonFrame1;
    self.navigationItem.titleView = self.titleL;
    
    [self.view sendSubviewToBack:self.functionToolView];
    
    [self checkPHAuthorizationStatus];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];

    [self updateUIWithConnectState];
    [self updateUIWithCameraModal];
    
    if (dvr.isConnected) {
        
        [self startLive];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"isConnected"];
    
    if (dvr.isConnected) {
        
        [self.realTimeViewing stop];
    }
}

- (BOOL)prefersStatusBarHidden{
    
    return self.isFullScreenMode;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"isConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateUIWithConnectState];
            [self updateUIWithCameraModal];

            BOOL isConnected = [change[@"new"] boolValue];
            if (isConnected) {
                [self startLive];
            }
            else{
                [self.realTimeViewing stop];
                
                if (self.isFullScreenMode)
                    [self clickFullScreenButton:nil];
                
                NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTJOINAPP"];
                if (![value isEqualToString:@"NO"]) {
                    [self performSegueWithIdentifier:@"GuideSegue" sender:nil];
                }
            }
        });
    }
}


- (void)checkPHAuthorizationStatus{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        
//        [self loadLocalAlbumCoverInfo];
        
    }else{
        
        if (status == PHAuthorizationStatusDenied) {
            
            [self showGetPHAuthorizationAlert];
            
        }else{
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    
//                    [self loadLocalAlbumCoverInfo];
                }
            }];
        }
    }
}

- (void)showGetPHAuthorizationAlert{
    
    [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"请允许访问iPhone的\"照片\"，否则无法使用下载功能！", nil) confirmHandler:^(UIAlertAction *action) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            
            NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
            NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
            if (iosVersionNumber >= 10) {
                
                [app openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
                
            }else{
                
                [app openURL:url];
            }
        }
    }];
}



#pragma mark - private method

- (void)updateUIWithConnectState{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    self.playerView.hidden = !dvr.isConnected;
    self.fullScreenButton.hidden = !dvr.isConnected;
    self.disconnectView.hidden = dvr.isConnected;
    
    if (!dvr.isConnected) {
        
        self.isRecording = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)updateUIWithCameraModal{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (dvr.modal == kAPKDVRModalAosibi) {
        self.captureButton.hidden = NO;
        self.xiongfengComponentsView.hidden = YES;
    }
    else if (dvr.modal == kAPKDVRModalXiongFeng){
        self.captureButton.hidden = YES;
        self.xiongfengComponentsView.hidden = NO;
    }
}

- (void)capturePhoto{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        //        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"未连接DVR", nil) confirmHandler:^(UIAlertAction *action) {
        //        }];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APKDVRCommandFactory captureCommand] execute:^(id responseObject) {
        
        [hud hideAnimated:NO];
        
        UIView *aView = self.isFullScreenMode ? self.realTimeViewing.view : self.view;
        MBProgressHUD *textHUD = [MBProgressHUD showHUDAddedTo:aView animated:YES];
        textHUD.mode = MBProgressHUDModeText;
        textHUD.label.text = NSLocalizedString(@"设备拍照成功！", nil);
        textHUD.userInteractionEnabled = NO;
        [textHUD hideAnimated:YES afterDelay:1.f];
        
    } failure:^(int rval) {
        
        [hud hideAnimated:NO];
        
        UIView *aView = self.isFullScreenMode ? self.realTimeViewing.view : self.view;
        MBProgressHUD *textHUD = [MBProgressHUD showHUDAddedTo:aView animated:YES];
        textHUD.mode = MBProgressHUDModeText;
        textHUD.label.text = NSLocalizedString(@"设备拍照失败！", nil);
        textHUD.userInteractionEnabled = NO;
        [textHUD hideAnimated:YES afterDelay:1.f];
    }];
}

- (void)setupFrames{
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat topLayoutGuide = statusBarHeight + navigationBarHeight;
    CGFloat bottomLayoutGuide = self.tabBarController.tabBar.frame.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat height = screenWidth / 16.f * 9.f;
    self.playerViewFrame1 = CGRectMake(0, topLayoutGuide, screenWidth, height);
    
    CGFloat X = screenWidth / 2.f - screenHeight / 2.f;
    CGFloat Y = screenHeight / 2.f - screenWidth / 2.f;
    self.playerViewFrame2 = CGRectMake(X, Y, screenHeight, screenWidth);
    
    CGFloat border = 20;
    CGFloat width = 50;
    height = 50;
    X = screenWidth - width - border;
    Y = CGRectGetMaxY(self.playerViewFrame1) - height - border;
    self.fullScreenButtonFrame1 = CGRectMake(X, Y, width, height);
    
    Y = border;
    self.fullScreenButtonFrame2 = CGRectMake(X, Y, width, height);
    
    
    width = 100;
    height = 100;
    X = screenWidth / 2.f - width / 2.f;
    CGFloat captureButtonBGHeight = screenHeight - CGRectGetMaxY(self.playerViewFrame1) - bottomLayoutGuide;
    CGFloat captureButtonTopBorder = (captureButtonBGHeight - width) / 2;
    Y = CGRectGetMaxY(self.playerViewFrame1) + captureButtonTopBorder;
    self.captureButtonFrame1 = CGRectMake(X, Y, width, height);
    
    Y = screenHeight - height - border;
    self.captureButtonFrame2 = CGRectMake(X, Y, width, height);
    
    width = screenWidth - border * 2;
    height = 72;
    X =  border;
    Y = CGRectGetMaxY(self.playerViewFrame1) + (captureButtonBGHeight - height) / 2;
    self.xiongfengComponentsViewFrame1 = CGRectMake(X, Y, width, height);
    
    Y = screenHeight - height - border;
    self.xiongfengComponentsViewFrame2 = CGRectMake(X, Y, width, height);

    
    width = width / 3;
    X = width * 0;
    Y = 0;
    self.captureButton2Frame1 = CGRectMake(X, Y, width, height);
    
    X = width * 1;
    self.videocamButtonFrame1 = CGRectMake(X, Y, width, height);

    X = width * 2;
    self.lockButtonFrame1 = CGRectMake(X, Y, width, height);
    
    X = (width - height) / 2;
    Y = height / 2 - width / 2;
    self.captureButton2Frame2 = CGRectMake(X, Y, height, width);
    
    X = CGRectGetWidth(self.xiongfengComponentsViewFrame1) / 2 - height / 2;
    Y = height / 2 - width / 2;
    self.videocamButtonFrame2 = CGRectMake(X, Y, height, width);
    
    X = CGRectGetWidth(self.xiongfengComponentsViewFrame1) - height - (width - height) / 2;
    Y = height / 2 - width / 2;
    self.lockButtonFrame2 = CGRectMake(X, Y, height, width);
}

- (void)startLive{
    
    if (self.isGettingRTSPUrl)
        return;
    
    self.isGettingRTSPUrl = YES;
    __weak typeof(self)weakSelf = self;
    [[APKDVRCommandFactory getLiveUrlCommand] execute:^(id responseObject) {
        
        weakSelf.isGettingRTSPUrl = NO;
//        if (weakSelf.tabBarController.selectedViewController != weakSelf.navigationController)
//            return;
        
        BOOL isRecording = [[responseObject objectForKey:@"isRecording"] boolValue];
        weakSelf.isRecording = isRecording;
        
        NSURL *url = [responseObject objectForKey:@"rtspUrl"];
        weakSelf.realTimeViewing.url = url;
        [weakSelf.realTimeViewing play];
        
    } failure:^(int rval) {
        
        weakSelf.isGettingRTSPUrl = NO;
    }];
}

#pragma mark - event response

- (IBAction)clickFileBtn:(UIButton *)sender {
    
    if ([APKDVR sharedInstance].isConnected) {
        NSString *fileType = sender.tag == 100 ? @"normal" : @"event";
        [APKDVR sharedInstance].fileType = fileType;
        [self performSegueWithIdentifier:@"DVRFileSegue" sender:nil];
    }else{
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"未连接DVR", nil) confirmHandler:^(UIAlertAction *action) {}];
    }

}


- (IBAction)clickLockButton:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected)
        return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APKDVRCommandFactory setCommandWithProperty:@"VideoLock" value:@"Lock"] execute:^(id responseObject) {
        
        [hud hideAnimated:YES];
        
        self.lockButton.hidden = YES;
        [self.lockRemainingTimeRecorder launchWithUpdateRemainingTimeHandler:^(int remainingTime) {
        
            if (remainingTime < 0) {
                
                self.lockRemainingTimeLabel.text = nil;
                self.lockButton.hidden = NO;
                
                self.lockRemainingTimeRecorder = nil;
            }
            else{
                
                self.lockRemainingTimeLabel.text = [NSString stringWithFormat:@"%ds",remainingTime];
            }
        }];
        
    } failure:^(int rval) {
        
        [hud hideAnimated:YES];
    }];
}

- (IBAction)clickVideocamButton:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected)
        return;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APKDVRCommandFactory setCommandWithProperty:@"Video" value:@"record"] execute:^(id responseObject) {
        
        self.isRecording = !self.isRecording;
        [hud hideAnimated:YES];
        
        //如果在锁定的过程中停止录像，锁定也会中断
        if (!self.isRecording && _lockRemainingTimeRecorder)
            [_lockRemainingTimeRecorder interrupt];
        
    } failure:^(int rval) {
        
        [hud hideAnimated:YES];
    }];
}

- (IBAction)clickCaptureButton2:(UIButton *)sender {
    
    [self capturePhoto];
}

- (IBAction)clickFullScreenButton:(UIButton *)sender {
    
    if (self.isFullScreenMode) {
        
        self.isFullScreenMode = !self.isFullScreenMode;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
        [self.fullScreenButton setImage:[UIImage imageNamed:@"fullScreen"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.playerView.transform = CGAffineTransformIdentity;
            self.fullScreenButton.transform = CGAffineTransformIdentity;
            self.captureButton.transform = CGAffineTransformIdentity;
            self.captureButton2.transform = CGAffineTransformIdentity;
            self.videocamButton.transform = CGAffineTransformIdentity;
            self.lockButton.transform = CGAffineTransformIdentity;
            self.lockRemainingTimeLabel.transform = CGAffineTransformIdentity;

            self.playerView.frame = self.playerViewFrame1;
            self.fullScreenButton.frame = self.fullScreenButtonFrame1;
            self.captureButton.frame = self.captureButtonFrame1;
            self.xiongfengComponentsView.frame = self.xiongfengComponentsViewFrame1;
            self.captureButton2.frame = self.captureButton2Frame1;
            self.videocamButton.frame = self.videocamButtonFrame1;
            self.lockButton.frame = self.lockButtonFrame1;
            self.lockRemainingTimeLabel.frame = self.lockButtonFrame1;
        }];
    }
    else{
        
        self.isFullScreenMode = !self.isFullScreenMode;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.tabBarController.tabBar setHidden:YES];
        [self.fullScreenButton setImage:[UIImage imageNamed:@"quit_fullScreen"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.playerView.frame = self.playerViewFrame2;
            self.fullScreenButton.frame = self.fullScreenButtonFrame2;
            self.captureButton.frame = self.captureButtonFrame2;
            self.xiongfengComponentsView.frame = self.xiongfengComponentsViewFrame2;
            self.captureButton2.frame = self.captureButton2Frame2;
            self.videocamButton.frame = self.videocamButtonFrame2;
            self.lockButton.frame = self.lockButtonFrame2;
            self.lockRemainingTimeLabel.frame = self.lockButtonFrame2;
            
            self.playerView.transform = CGAffineTransformRotate(self.playerView.transform, M_PI_2);
            self.fullScreenButton.transform = CGAffineTransformRotate(self.fullScreenButton.transform, M_PI_2);
            self.captureButton.transform = CGAffineTransformRotate(self.captureButton.transform, M_PI_2);
            self.captureButton2.transform = CGAffineTransformRotate(self.captureButton2.transform, M_PI_2);
            self.videocamButton.transform = CGAffineTransformRotate(self.videocamButton.transform, M_PI_2);
            self.lockButton.transform = CGAffineTransformRotate(self.lockButton.transform, M_PI_2);
            self.lockRemainingTimeLabel.transform = CGAffineTransformRotate(self.lockRemainingTimeLabel.transform, M_PI_2);
        }];
    }
}

- (IBAction)clickCaptureButton:(UIButton *)sender {
    
    [self capturePhoto];
}

#pragma mark - setter


- (void)setIsRecording:(BOOL)isRecording{
    
    _isRecording = isRecording;
    
    NSString *imageName = isRecording ? @"videocam" : @"videocam_off";
    [self.videocamButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    self.lockButton.enabled = isRecording;
}

#pragma mark - getter

- (APKLockRemainingTimeRecorder *)lockRemainingTimeRecorder{
    
    if (!_lockRemainingTimeRecorder) {
        
        _lockRemainingTimeRecorder = [[APKLockRemainingTimeRecorder alloc] init];
    }
    return _lockRemainingTimeRecorder;
}

- (APKRealTimeViewingController *)realTimeViewing{
    
    if (!_realTimeViewing) {
        
        for (id obj in self.childViewControllers) {
            if ([obj isKindOfClass:[APKRealTimeViewingController class]]) {
                _realTimeViewing = obj;
                break;
            }
        }
    }
    return _realTimeViewing;
}

-(UILabel *)titleL
{
    if (!_titleL) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, -20, 200, 40)];
        label.text = @"MiBo Car";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:81.f/255.f green:192.f/255.f blue:172.f/255.f alpha:1];
        label.font = [UIFont systemFontOfSize:18.0];
        _titleL = label;
    }
    return _titleL;
}

@end
