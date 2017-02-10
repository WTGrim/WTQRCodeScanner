//
//  Scanner.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "Scanner.h"
#import <AVFoundation/AVFoundation.h>

@interface Scanner ()

@property(nonatomic, weak)UIView *parentView;
@property(nonatomic, assign)CGRect scanFrame;
@property(nonatomic, copy)void(^competed)(NSString *);

@end

@implementation Scanner{
    
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;//预览图层
    CALayer *_drawLayer;//绘制图层
    NSInteger *_currentCount;
}

#pragma mark - 生成二维码
+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void (^)(UIImage *))completed{
    
    [self generateQrcodeImage:cardName centerImage:centerImage scale:0.2 completed:completed];
}

+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage scale:(CGFloat)scale completed:(void (^)(UIImage *))completed{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setDefaults];
        [filter setValue:[cardName dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
        CIImage *outputImage = filter.outputImage;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(10, 10);
        CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:transformImage fromRect:transformImage.extent];
        UIImage *qrImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(cgImage);
        
        if (centerImage) {
            qrImage = [self qrImage:qrImage centerImage:centerImage scale:scale];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(qrImage);
        });
    });
}

+ (UIImage *)qrImage:(UIImage *)qrImage centerImage:(UIImage *)centerImage scale:(CGFloat)scale{
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectMake(0, 0, qrImage.size.width * screenScale, qrImage.size.height * screenScale);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, screenScale);
    [qrImage drawInRect:rect];
    
    CGSize centerImageSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
    CGFloat x = (rect.size.width - centerImageSize.width) * 0.5;
    CGFloat y = (rect.size.height - centerImageSize.height) * 0.5;
    [centerImage drawInRect:CGRectMake(x, y, centerImageSize.width, centerImageSize.height)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:resultImage.CGImage scale:screenScale orientation:UIImageOrientationUp];
}

#pragma mark - 扫描图像
+ (void)scanImage:(UIImage *)image completed:(void (^)(NSArray *))completed{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        
    });
}

@end
