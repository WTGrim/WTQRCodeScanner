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
    
    UIImageView *_borderImageView;
}


- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self initView];
    }
    return self;
}


- (void)initView{
    
    
    self.clipsToBounds = YES;
    _borderImageView = [UIImageView alloc]initWithImage:[UIImage imageNamed:<#(nonnull NSString *)#>]
}

@end
