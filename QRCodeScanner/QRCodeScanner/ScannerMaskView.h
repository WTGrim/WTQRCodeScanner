//
//  ScannerMaskView.h
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/10.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

//遮罩层
@interface ScannerMaskView : UIView

+ (instancetype)maskViewWithFrame:(CGRect)frame clipFrame:(CGRect)clipFrame;

@property(nonatomic, assign)CGRect clipFrame;

@end


//扫描框
@interface ScannerBorder : UIView

- (void)beginScanAnimation;
- (void)endScanAnimation;

@end
