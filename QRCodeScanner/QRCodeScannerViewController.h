//
//  QRCodeScannerViewController.h
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/10.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeScannerViewController : UIViewController

- (instancetype)initWithCardName:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void(^)(NSString *))completed;

@end
