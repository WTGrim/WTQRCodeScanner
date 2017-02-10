//
//  ScannerMaskView.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/10.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "ScannerMaskView.h"

@implementation ScannerMaskView

+ (instancetype)maskViewWithFrame:(CGRect)frame clipFrame:(CGRect)clipFrame{
    
    ScannerMaskView *maskView = [[self alloc]initWithFrame:frame];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.clipFrame = clipFrame;
    return maskView;
}

- (void)setClipFrame:(CGRect)clipFrame{
    
    _clipFrame = clipFrame;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithWhite:0 alpha:0.4] setFill];
    CGContextFillRect(context, rect);
    CGContextClearRect(context, self.clipFrame);
    
    [[UIColor colorWithWhite:0.8 alpha:1] setStroke];
    CGContextStrokeRectWithWidth(context, CGRectInset(self.clipFrame, 1, 1), 1); //内边距
}

@end


@implementation ScannerBorder{
    
    UIImageView *_line;
}


- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self initView];
    }
    return self;
}


- (void)initView{
    
    
    self.clipsToBounds = YES;
    _line = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scanLine"]];
    _line.frame = CGRectMake(0, 0, self.bounds.size.width, _line.bounds.size.height);
    _line.center = CGPointMake(self.bounds.size.width * 0.5, 0);
    [self addSubview:_line];
    
    //设置边角图像
    for (int i = 1; i < 5; i++) {
        
        UIImageView *border = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"scan%d", i]]];
        [self addSubview:border];
        CGFloat marginW = self.bounds.size.width - border.bounds.size.width;
        CGFloat marginH = self.bounds.size.height - border.bounds.size.height;
        
        switch (i) {
            case 2:
                border.frame = CGRectOffset(border.frame, marginW, 0);
                break;
            case 3:
                border.frame = CGRectOffset(border.frame, 0, marginH);
                break;
            case 4:
                border.frame = CGRectOffset(border.frame, marginW, marginH);
                break;
            default:
                break;
        }

    }
}

#pragma mark - 开始扫描
- (void)beginScanAnimation{
    
    [self endScanAnimation];
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [UIView setAnimationRepeatCount:MAXFLOAT];
        _line.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height);
    } completion:nil];
    
}

#pragma mark - 结束扫描
- (void)endScanAnimation{
    
    [self.layer removeAllAnimations];
    _line.center = CGPointMake(self.bounds.size.width * 0.5, 0);
}

@end
