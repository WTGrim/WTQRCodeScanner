//
//  Scanner.h
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

//二维码/条形码扫描器
#import <UIKit/UIKit.h>

@interface Scanner : NSObject

//指定scanner在哪个视图上
+ (instancetype)scannerWithView:(UIView *)view scannerFrame:(CGRect)scannerFrame completed:(void(^)(NSString *))completed;

//扫描二维码图像
+ (void)scanImage:(UIImage *)image completed:(void(^)(NSArray *))completed;

//生成二维码图像(异步)
+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void(^)(UIImage *))completed;

//生成二维码并指定中心图片的占的大小(异步)
+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage scale:(CGFloat)scale completed:(void (^)(UIImage *))completed;

//开始扫描
+ (void)beginScan;

//结束扫描
+ (void)endScan;

@end
