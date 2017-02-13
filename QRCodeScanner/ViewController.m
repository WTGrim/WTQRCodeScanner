//
//  ViewController.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/9.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScannerViewController.h"
#import "Scanner.h"
@interface ViewController ()

@property(nonatomic, strong)NSString *cardName;
@property(nonatomic, strong)UIImage *centerImage;
@property(nonatomic, strong)UILabel *resultLabel;
@property(nonatomic, strong)UIImageView *qrImageView;

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
    _resultLabel.text = @"这里是扫描结果";
    _resultLabel.center = self.view.center;
    _resultLabel.textColor = [UIColor redColor];
    _resultLabel.font = [UIFont systemFontOfSize:16];
    [_resultLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_resultLabel];
    
    
    UIButton *cardButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 40, self.view.bounds.size.height - 30, 80, 30)];
    [cardButton addTarget:self action:@selector(cardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cardButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    cardButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [cardButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [self.view addSubview:cardButton];
}

//扫描及返回的结果
- (void)onClick{
    
    __weak typeof(self)weakSelf = self;
    QRCodeScannerViewController *vc = [[QRCodeScannerViewController alloc]initWithCardName:self.cardName centerImage:self.centerImage completed:^(NSString *result) {
        
        weakSelf.resultLabel.text = result;
    }];
    [self showDetailViewController:vc sender:nil];
}

- (void)cardButtonClick{
    
    if (!_qrImageView) {
        _qrImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 240, 200, 200)];
        CGPoint center = _qrImageView.center;
        center.x = self.view.center.x;
        _qrImageView.center = center;
        [self.view addSubview:_qrImageView];
    }
    UIImage *image = [UIImage imageNamed:@"QR"];
    [Scanner generateQrcodeImage:@"生成二维码" centerImage:image completed:^(UIImage *image) {
        
        _qrImageView.image = image;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
