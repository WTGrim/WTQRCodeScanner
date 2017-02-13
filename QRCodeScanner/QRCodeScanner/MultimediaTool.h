//
//  MultimediaTool.h
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/13.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultimediaTool : NSObject

//闪光灯
+ (void)openLight:(BOOL)Open;

//声音和震动
+ (void)openSound:(BOOL)sound shake:(BOOL)shake;

//在浏览器中打开
+ (void)showDetailMessageInSafari:(NSString *)message succeed:(void(^)(NSString *result))succeed failed:(void(^)(NSError *error))failed;

@end
