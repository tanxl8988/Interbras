//
//  APKRtspPlayerController.m
//  万能AIT
//
//  Created by Mac on 17/12/19.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRealTimeViewingController.h"
#import "MobileVLCKit/VLCMediaPlayer.h"

@interface APKRealTimeViewingController ()<VLCMediaPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong,nonatomic) UIView *displayView;
@property (strong,nonatomic) VLCMediaPlayer *player;

@end

@implementation APKRealTimeViewingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIViewController *vc = [[UIViewController alloc] init];
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:vc.view];
    [self.view sendSubviewToBack:vc.view];
    self.displayView = vc.view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self stop];
}

#pragma mark - public method

- (void)play{
    
    if (!self.url)
        return;
    
    switch (self.player.state) {
        case VLCMediaPlayerStateOpening:
        case VLCMediaPlayerStateBuffering:
        case VLCMediaPlayerStatePlaying:
            return;
            break;
        case VLCMediaPlayerStatePaused:
            [self.player play];
            return;
        default:
            break;
    }
    
    self.playButton.hidden = YES;
    [self.flower startAnimating];
    
    VLCMedia *media = [VLCMedia mediaWithURL:self.url];
    [self.player setMedia:media];
    [self.player play];
}

- (void)stop{
    
//    NSLog(@"stop live in state:%d",(int)self.player.state);
    switch (self.player.state) {
        case VLCMediaPlayerStateOpening:
        case VLCMediaPlayerStateBuffering:
        case VLCMediaPlayerStatePlaying:
        case VLCMediaPlayerStatePaused:
            [self.player stop];
            break;
        default:
            break;
    }
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    
//    NSLog(@"------>%d",self.player.state);
    switch (self.player.state) {
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateError:
        case VLCMediaPlayerStatePaused:
            if (self.playButton.hidden)
                self.playButton.hidden = NO;
            if (self.flower.isAnimating)
                [self.flower stopAnimating];
            break;
        case VLCMediaPlayerStatePlaying:
            if (!self.playButton.hidden)
                self.playButton.hidden = YES;
            if (self.flower.isAnimating)
                [self.flower stopAnimating];
            
            break;
        case VLCMediaPlayerStateOpening:
        case VLCMediaPlayerStateBuffering:
            if (!self.playButton.hidden)
                self.playButton.hidden = YES;
            if (!self.flower.isAnimating)
                [self.flower startAnimating];
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
//    NSLog(@"number of video tracks:%d",self.player.numberOfAudioTracks);

    if (self.flower.isAnimating)
        [self.flower stopAnimating];
}

#pragma mark - event response

- (IBAction)clickPlayButton:(UIButton *)sender {
    
    [self play];
}

#pragma mark - getter

- (VLCMediaPlayer *)player{
    
    if (!_player) {
        
        NSString *caching = [NSString stringWithFormat:@"--network-caching=%d",800];
        NSString *jitter = [NSString stringWithFormat:@"--clock-jitter=%d",800];
        NSArray *options = @[caching,jitter,@"--extraintf=",@"--gain=0"];
//        NSArray *options = @[@"--network-caching=400",@"--extraintf="];
        _player = [[VLCMediaPlayer alloc] initWithOptions:options];
        _player.delegate = self;
        _player.drawable = self.displayView;
    }
    return _player;
}


@end
