//
//  PhotoViewController.m
//  jqdl
//
//  Created by Stephen Chin on 2017/4/5.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "PhotoViewController.h"
#import "JZNavigationExtension.h"
#import "UIImageView+AFNetworking.h"

@interface PhotoViewController (){
    BOOL showStatus;
    UILabel *pageLabel;
    UILabel *bottomLabel;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    showStatus = YES;
    
//    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.jz_navigationBarBackgroundAlpha = 0.f;
    [_myScrollView setPagingEnabled:YES];
    _myScrollView.bounces = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor blackColor];
    [self initUI];
}

-(void)initUI{
    if (_images) {
        CGFloat maxX = 0;
        for (int i = 0 ; i < _images.count; i++) {
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(i*Main_Screen_Width, 0, Main_Screen_Width, Main_Screen_Height)];
            [imageview setImageWithURL:[NSURL URLWithString:[_images objectAtIndex:i]]];
            [imageview setContentMode:UIViewContentModeScaleAspectFit];
            [_myScrollView addSubview:imageview];
            maxX = CGRectGetMaxX(imageview.frame);
        }
        [_myScrollView setContentSize:CGSizeMake(maxX, Main_Screen_Height)];
    }
    
    bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, Main_Screen_Height - 35, 0, 0)];
    bottomLabel.font = SYSTEMFONT(15);
    bottomLabel.text = _name;
    bottomLabel.textColor = [UIColor whiteColor];
    [bottomLabel sizeToFit];
    [self.view addSubview:bottomLabel];
    
    pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(Main_Screen_Width - 50, CGRectGetMinY(bottomLabel.frame), 30, CGRectGetHeight(bottomLabel.frame))];
    pageLabel.font = SYSTEMFONT(15);
    pageLabel.text = [NSString stringWithFormat:@"1/%ld",_images.count];
    pageLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:pageLabel];
}

-(void)tapView{
    if (showStatus) {
        showStatus = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [bottomLabel setHidden:YES];
        [pageLabel setHidden:YES];
    }else{
        showStatus = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [bottomLabel setHidden:NO];
        [pageLabel setHidden:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - UIScrollViewDelegate

//- (void) scrollViewDidScroll:(UIScrollView *)sender {
//    // 得到每页宽度
//    CGFloat pageWidth = sender.frame.size.width;
//    // 根据当前的x坐标和页宽度计算出当前页数
//    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    DLog(@"%d",currentPage);
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    NSString *text = pageLabel.text;
    NSRange range = [text rangeOfString:@"/"];
    NSString *s2 = [text substringFromIndex:range.location];
    pageLabel.text = [NSString stringWithFormat:@"%d%@",currentPage + 1,s2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
