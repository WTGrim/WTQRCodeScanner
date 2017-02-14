//
//  QRCodeScannerViewController.m
//  QRCodeScanner
//
//  Created by Dwt on 2017/2/10.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "QRCodeScannerViewController.h"
#import "Scanner.h"
#import "ScannerMaskView.h"
#import "MultimediaTool.h"

#define kMaxImageSize CGSizeMake(1000, 1000)
@interface QRCodeScannerViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, strong)NSString *cardName;
@property(nonatomic, strong)UIImage *centerImage;
@property(nonatomic, copy)void(^completed)(NSString *);

@end

@implementation QRCodeScannerViewController{
    
    Scanner *_scanner;
    ScannerBorder *_scanBorder;
    UILabel *_tipsLabel;
    
}

- (instancetype)initWithCardName:(NSString *)cardName centerImage:(UIImage *)centerImage completed:(void (^)(NSString *))completed{
    
    if (self = [super init]) {
        self.cardName = cardName;
        self.centerImage = centerImage;
        self.completed = completed;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    //扫描器
    __weak typeof(self)weakSelf = self;
    _scanner = [Scanner scannerWithPrarentView:self.view scannerFrame:_scanBorder.frame completed:^(NSString *result) {
        
        weakSelf.completed(result);
        [weakSelf dismiss];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_scanBorder beginScanAnimation];
    [_scanner beginScan];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_scanBorder endScanAnimation];
    [_scanner  endScan];
}

- (void)initView{
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self initNav];
    [self initScanBorder];
    [self initTips];
}

- (void)initNav{
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    
    self.title = @"扫一扫";
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarClick)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarClick)];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height - 30, 40, 30)];
    [closeButton addTarget:self action:@selector(leftBarClick) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    
    UIButton *photoButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 30, 40, 30)];
    [photoButton addTarget:self action:@selector(rightBarClick) forControlEvents:UIControlEventTouchUpInside];
    [photoButton setTitle:@"相册" forState:UIControlStateNormal];
    [photoButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:photoButton];
    
    UIButton *flashButton = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - 40) * 0.5, self.view.bounds.size.height - 30, 40, 30)];
    [flashButton addTarget:self action:@selector(flashClick:) forControlEvents:UIControlEventTouchUpInside];
    [flashButton setTitle:@"闪光灯" forState:UIControlStateNormal];
    [flashButton sizeToFit];
    [flashButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:flashButton];
}

- (void)initScanBorder{
    
    CGFloat width = self.view.bounds.size.width - 100;
    _scanBorder = [[ScannerBorder alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    _scanBorder.center = self.view.center;
    _scanBorder.tintColor = self.navigationController.navigationBar.tintColor;
    [self.view addSubview:_scanBorder];
    
    ScannerMaskView *maskView = [ScannerMaskView maskViewWithFrame:self.view.bounds clipFrame:_scanBorder.frame];
    [self.view insertSubview:maskView atIndex:0];
    
}

- (void)initTips{
    
    _tipsLabel = [[UILabel alloc]init];
    _tipsLabel.font = [UIFont systemFontOfSize:12];
    _tipsLabel.text = @"将二维码/条形码放入框中，即可自动扫描";
    _tipsLabel.textColor = [UIColor whiteColor];
    [_tipsLabel sizeToFit];
    _tipsLabel.center = CGPointMake(_scanBorder.center.x, CGRectGetMaxY(_scanBorder.frame) + 60);
    [_tipsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_tipsLabel];
    
}

- (void)leftBarClick{
    [self dismiss];
}

- (void)rightBarClick{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        _tipsLabel.text = @"相册无法访问";
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.view.backgroundColor = [UIColor whiteColor];
    imagePicker.delegate = self;
    [self showDetailViewController:imagePicker sender:nil];
}

#pragma mark - 闪光灯
- (void)flashClick:(UIButton *)btn{
    
    NSLog(@"点击了闪光灯");
    if (btn.isSelected == YES) {
        [MultimediaTool openLight:btn.isSelected];
        btn.selected = !btn.selected;
    }else{
        btn.selected = YES;
        [MultimediaTool openLight:YES];
    }

}


#pragma mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = [self resizeImage:info[UIImagePickerControllerOriginalImage]];
    //图像扫描
    __weak typeof(self)weakSelf = self;
    [Scanner scanImage:image completed:^(NSArray *results) {
        
        if (results.count > 0) {
            weakSelf.completed(results.firstObject);
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                [weakSelf dismiss];
            }];
        }else{
            _tipsLabel.text = @"没有识别到二维码";
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (UIImage *)resizeImage:(UIImage *)image{
    
    if (image.size.width < kMaxImageSize.width && image.size.height < kMaxImageSize.height) {
        return image;
    }
    CGFloat ratioW =  kMaxImageSize.width / image.size.width;
    CGFloat ratioH = kMaxImageSize.height / image.size.height ;
    CGFloat ratio = MIN(ratioW, ratioH);
    CGSize size = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)dismiss{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
