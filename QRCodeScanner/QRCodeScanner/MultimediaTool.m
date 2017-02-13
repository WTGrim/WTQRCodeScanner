//
//  MultimediaTool.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/13.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "MultimediaTool.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@implementation MultimediaTool


+ (void)openLight:(BOOL)Open{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) return;
    if (Open) {
        if (device.torchMode != AVCaptureTorchModeOn ||device.flashMode != AVCaptureFlashModeOn) {
            
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
            [device unlockForConfiguration];
        }else{
            if (device.torchMode != AVCaptureTorchModeOff || device.flashMode != AVCaptureFlashModeOff) {
                [device lockForConfiguration:nil];
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
            }
        }
    }
}

+ (void)openSound:(BOOL)sound shake:(BOOL)shake{
    //开启声音
    if (sound) {
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"]], &soundId);
        AudioServicesPlaySystemSound(soundId);
    }
    
    //开启震动
    if (shake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

+ (void)showDetailMessageInSafari:(NSString *)message succeed:(void (^)(NSString *))succeed failed:(void (^)(NSError *))failed{
    NSString *newURl = [[self new] judgeSpecialURL:message];
    NSURL *url = [NSURL URLWithString:newURl];
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([newURl isEqualToString:message]) {
        
        //对IOS10进行适配
        if ([app respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [app openURL:url options:@{} completionHandler:nil];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            succeed(@"成功跳转");
            [[UIApplication sharedApplication] openURL:url];
        }else{
            NSError *error;
            failed(error);
        }
    }else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (NSString *)judgeSpecialURL:(NSString *)urlString {
    NSString *newURL = nil;
    if ([urlString hasPrefix:@"http://qm.qq.com"]) {
        newURL = @"mqq://";
    }else if ([urlString hasPrefix:@"http://weixin.qq.com"]){
        newURL = @"weixin://";
    }else if ([urlString hasPrefix:@"http://weibo.cn"]){
        newURL = @"sinaweibo://";
    }else if ([urlString hasPrefix:@"https://qr.alipay.com"]){
        newURL = @"alipay://";
    }else{
        newURL = urlString;
    }
    return newURL;
}


@end
