//
//  Scanner.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "Scanner.h"
#import <AVFoundation/AVFoundation.h>
#import "MultimediaTool.h"

#define kMaxDetectCount 20
@interface Scanner ()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, weak)UIView *parentView;
@property(nonatomic, assign)CGRect scanFrame;
@property(nonatomic, copy)void(^competed)(NSString *);

@end

@implementation Scanner{
    
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;//预览图层
    CALayer *_drawLayer;//绘制图层
    NSInteger _currentCount;
}


+ (instancetype)scannerWithPrarentView:(UIView *)view scannerFrame:(CGRect)scannerFrame completed:(void (^)(NSString *))completed{
    
    NSAssert(completed != nil, @"必须传入完成回调");

    return [[self alloc]initWithView:view scannerFrame:scannerFrame completed:completed];
}

- (instancetype)initWithView:(UIView *)view scannerFrame:(CGRect)scannerFrame completed:(void (^)(NSString *))completed{
    
    if (self = [super init]) {
        self.parentView = view;
        self.scanFrame = scannerFrame;
        self.competed = completed;
        
        [self initSession];
    }
    return self;
}

- (void)initSession{
    
    //设置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if (!input) {
        NSLog(@"创建输入设备失败");
        return;
    }
    
    //输出
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    
    //设置会话
    _session = [[AVCaptureSession alloc]init];
    if (![_session canAddInput:input] || ![_session canAddOutput:output]) {
        NSLog(@"添加设备失败");
        _session = nil;
        return;
    }
    [_session addInput:input];
    [_session addOutput:output];
    
    output.metadataObjectTypes = output.availableMetadataObjectTypes;
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置预览层和绘制图层
    [self initLayers];
}

- (void)initLayers{
    
    if (!self.parentView || !_session) {
        NSLog(@"父视图不存在");
        return;
    }
    
    _drawLayer = [CALayer layer];
    _drawLayer.frame = self.parentView.bounds;
    [self.parentView.layer insertSublayer:_drawLayer atIndex:0];
    
    //预览图层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.parentView.bounds;
    [self.parentView.layer insertSublayer:_previewLayer atIndex:0];
    
}
#pragma mark - 生成二维码
+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void (^)(UIImage *))completed{
    
    [self generateQrcodeImage:cardName centerImage:centerImage scale:0.2 completed:completed];
}

+ (void)generateQrcodeImage:(NSString *)cardName centerImage:(UIImage *)centerImage scale:(CGFloat)scale completed:(void (^)(UIImage *))completed{
    
    NSAssert(completed != nil, @"回调不能为空");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setDefaults];
        [filter setValue:[cardName dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
        
        CIImage *outputImage = filter.outputImage;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(10, 10);
        CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:transformImage fromRect:transformImage.extent];
        UIImage *qrImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
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
    
    NSAssert(completed != nil, @"回调不能为空");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        CIImage *ciImage = [[CIImage alloc]initWithImage:image];
        //返回通过置信系数过滤的特征
        NSArray *features = [detector featuresInImage:ciImage];
        
        NSMutableArray *array = [NSMutableArray array];
        for (CIQRCodeFeature *feature in features) {
            
            [array addObject:feature.messageString];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(array.copy);
        });
        
    });
}

#pragma mark - 开始/结束扫描
- (void)beginScan{
    
    if ([_session isRunning]) return;
    _currentCount = 0;
    [_session startRunning];
}

- (void)endScan{
    
    if (![_session isRunning]) return;
    [_session stopRunning];
}

#pragma mark - 清理图层
- (void)clearLayers{
    
    if (_drawLayer.sublayers.count == 0) return;
    [_drawLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    [self clearLayers];
    for (id obj in metadataObjects) {
        
        if (![obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) return;
        
        //转换对象坐标
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
        if (!CGRectContainsRect(self.scanFrame, readableObject.bounds)) {
            continue;
        }
        
        if (_currentCount++ < kMaxDetectCount) {
            //绘制
            [self drawShape:readableObject];
        }else{
            
            [self endScan];
            
            //扫描完成
            [MultimediaTool openSound:YES shake:NO];
            //完成
            if (self.competed) {
                self.competed(readableObject.stringValue);
            }
            [MultimediaTool showDetailMessageInSafari:readableObject.stringValue succeed:^(NSString *result) {
                NSLog(@"成功");
            } failed:^(NSError *error) {
                
            }];
        }
    }
}

#pragma mark - 绘制图形
- (void)drawShape:(AVMetadataMachineReadableCodeObject *)obj{
    
    if (!obj.corners.count) return;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 4;
    shapeLayer.strokeColor = [UIColor greenColor].CGColor;   //边线颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [self drawPath:obj.corners];
    [_drawLayer addSublayer:shapeLayer];
}

#pragma mark - 获取路径
- (CGPathRef)drawPath:(NSArray *)corners{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    NSInteger index = 0;
    
    //获取第一个点
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)(corners[index++]), &point);
    [path moveToPoint:point];
    
    //遍历
    while (index < corners.count) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)(corners[index++]), &point);
        [path addLineToPoint:point];
    }
    [path closePath];
    return path.CGPath;
}



@end
