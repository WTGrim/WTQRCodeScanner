//
//  QRCodeScannerController.h
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

//二维码扫描界面
#import <UIKit/UIKit.h>

@interface QRCodeScannerController : UINavigationController

//实例化导航器
+ (instancetype)scannerWithCardName:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void(^)(NSString *result))completed;
//生成二维码图像
+ (instancetype)CardImageWithCardName:(NSString *)cardName centerImage:(UIImage *)centerImage centerImageScale:(CGFloat)centerImageScale completed:(void(^)(UIImage *image))completed;

- (void)setTitleColor:(UIColor *)titleColor tintColor:(UIColor *)tintColor;

@end
