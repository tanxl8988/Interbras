//
//  APKDVR.m
//  AITBrain
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVR.h"
#import "APKWifiTool.h"
#import "APKDVRCommandFactory.h"
#import <UIKit/UIKit.h>

#define LASTDVRMODAL @"lastDVRModal"

@implementation APKDVR

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
    
        APKDVRModal modal = [[NSUserDefaults standardUserDefaults] integerForKey:LASTDVRMODAL];
        _modal = modal;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

+ (instancetype)sharedInstance{
    
    static APKDVR *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[APKDVR alloc] init];
    });
    
    return instance;
}

#pragma mark - public method

- (void)tryToUpdateConnectState{
    
    NSString *aitWifiAddress = @"192.72.1.1";
    NSString *wifiAddress = [APKWifiTool getWifiAddress];
//    NSString *aitWifiAddress = @"192.168.2.1";
    BOOL isConnectedDVRWifi = [wifiAddress isEqualToString:aitWifiAddress];
    if (isConnectedDVRWifi && !self.isConnected) {
        
        [[APKDVRCommandFactory getSettingInfoCommand] execute:^(id responseObject) {
            
            self.settingInfo = responseObject;
            NSString *version = self.settingInfo.FWVersion;
            if ([version hasPrefix:@"RR530"]) {
                self.modal = kAPKDVRModalAosibi;
            }
            else if ([version hasPrefix:@"RR535"] || [version isEqualToString:@"1207"]){
                self.modal = kAPKDVRModalXiongFeng;
            }
            else{
                NSLog(@"⚠️连接的不是我们的DVR！");
//                return;
            }
            self.isConnected = YES;
            
        } failure:^(int rval) {
            
        }];
    }
    else if (!isConnectedDVRWifi /*&& self.isConnected*/){
        
        self.settingInfo = nil;
        self.isConnected = NO;
    }
}

#pragma mark - private method

- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    
        [self tryToUpdateConnectState];
        
    }else if([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){

        if (self.isConnected) {
            
            self.settingInfo = nil;
            self.isConnected = NO;
        }
    }
}

#pragma mark - setter

- (void)setModal:(APKDVRModal)modal{
    
    _modal = modal;
    
    [[NSUserDefaults standardUserDefaults] setInteger:modal forKey:LASTDVRMODAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
