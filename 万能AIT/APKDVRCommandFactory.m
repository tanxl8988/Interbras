//
//  APKDVRCommandFactory.m
//  Aigo
//
//  Created by Mac on 17/6/30.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRCommandFactory.h"
#import "APKAITCGI.h"
#import "APKDVRFile.h"
#import "APKDVRSettingInfoResponseObjectHandler.h"
#import "APKGetDVRFileListResponseObjectHandler.h"
#import "APKGetLiveUrlResponseObjectHandler.h"
#import "APKWifiInfoResponseObjectHandler.h"

@implementation APKDVRCommandFactory

+ (APKDVRCommand *)rebotWifiCommand{
    
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net&value=reset";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)modifyWifiCommandWithAccount:(NSString *)account password:(NSString *)password{
    
    NSString *url = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net.WIFI_AP.SSID&value=%@&property=Net.WIFI_AP.CryptoKey&value=%@",account,password];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)getWifiInfoCommand{
    
    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Net.WIFI_AP.SSID&property=Net.WIFI_AP.CryptoKey";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKWifiInfoResponseObjectHandler new]];
    return command;

}

+ (APKDVRCommand *)setCommandWithProperty:(NSString *)property value:(NSString *)value{
    
    NSString *url = [APKAITCGI setCGIWithProperty:property value:value];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)getLiveUrlCommand{

    NSString *url = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.*";
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKGetLiveUrlResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)deleteCommandWithFileName:(NSString *)fileName{
    
    NSString *url = [APKAITCGI deleteCGIWithFileName:fileName];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)getFileListCommandWithFileType:(NSInteger)type count:(NSInteger)count offset:(NSInteger)offset{
    
    NSString *format = nil;
    NSString *property = nil;
    if (type == APKFileTypeCapture) {//photo
        format = @"all";
        property = @"Photo";
    }else if (type == APKFileTypeVideo){//video
        format = @"all";
        property = @"Normal";
    }else if (type == APKFileTypeEvent){//event
        format = @"all";
        property = @"Event";
    }else{
        return nil;
    }
    
    APKGetDVRFileListResponseObjectHandler *handler = [[APKGetDVRFileListResponseObjectHandler alloc] init];
    handler.fileType = type;
    NSString *url = [APKAITCGI getDVRFileListCGIWithFileFormat:format property:property offset:offset count:count];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:handler];
    return command;
}

+ (APKDVRCommand *)getSettingInfoCommand{
    
    NSString *url = [APKAITCGI getSettingInfoCGI];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRSettingInfoResponseObjectHandler new]];
    return command;
}

+ (APKDVRCommand *)captureCommand{
    
    NSString *url = [APKAITCGI setCGIWithProperty:@"Video" value:@"capture"];
    APKDVRCommand *command = [APKDVRCommand commandWithUrl:url responseObjectHandler:[APKDVRCommandResponseObjectHandler new]];
    return command;
}

@end
