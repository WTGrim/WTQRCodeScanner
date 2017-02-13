//
//  ViewController.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScannerViewController.h"
@interface ViewController ()

@property(nonatomic, strong)NSString *cardName;
@property(nonatomic, strong)UIImage *centerImage;
@property(nonatomic, strong)UILabel *resultLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initView];
}

- (void)initView{
    
    UIButton *scanButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 60, 30)];
    scanButton.center = CGPointMake(self.view.center.x, 100);
    [scanButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    _resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.5, self.view.bounds.size.width, 20)];
    _resultLabel.text = @"扫描结果";
    _resultLabel.center = self.view.center;
    _resultLabel.textColor = [UIColor redColor];
    _resultLabel.font = [UIFont systemFontOfSize:16];
    [_resultLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_resultLabel];
}

- (void)onClick{
    
    __weak typeof(self)weakSelf = self;
    QRCodeScannerViewController *vc = [[QRCodeScannerViewController alloc]initWithCardName:self.cardName centerImage:self.centerImage completed:^(NSString *result) {
        
        weakSelf.resultLabel.text = result;
    }];
    [self showDetailViewController:vc sender:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
