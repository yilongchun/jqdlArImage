//
//  DetailViewController.m
//  WikitudeTest
//
//  Created by Stephen Chin on 16/9/23.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "DetailViewController.h"
#import "BMAdScrollView.h"
#import "JZNavigationExtension.h"
#import "UILabel+SetLabelSpace.h"
#import "Player.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.navigationController.navigationBar.translucent = YES;
    self.jz_navigationBarBackgroundHidden = YES;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 0.f;
    
    
    
    
    [self setContent];
}

//设置内容
-(void)setContent{
    //顶部广告
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:[_poiDetails objectForKey:@"image"], nil];
    NSMutableArray *strArr = [NSMutableArray arrayWithObjects:@"1", nil];
    
    
    
    
    
    BMAdScrollView *adView = [[BMAdScrollView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 250) images:arr titles:strArr];
    [_myScrollView addSubview:adView];
    //标题
    NSString *slogan = @"海底隧道";
    UILabel *titleLabel = [UILabel new];
    CGRect titleRect = CGRectMake(15, 210, Main_Screen_Width - 50, 30);
    [titleLabel setFrame:titleRect];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.text = slogan;
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor=[UIColor whiteColor];
    [_myScrollView addSubview:titleLabel];
    //解说按钮
    UIButton *jieshuoBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(adView.frame) + 10, 98, 36)];
    [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
    [jieshuoBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [_myScrollView addSubview:jieshuoBtn];
    //文本介绍
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(jieshuoBtn.frame) + 12, Main_Screen_Width - 50, 10)];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = RGB(135, 135, 135);
    contentLabel.text = @"武汉东湖海洋世界坐落在著名的国家风景区武汉东湖，展示千余种万余尾海洋珍惜鱼类。整个展馆由八个展区组成－热带鱼林馆、海底隧道、海洋生物馆、长江鱼馆、海洋剧场、企鹅馆、海底隧道...";
    [contentLabel sizeToFit];
    [_myScrollView addSubview:contentLabel];
    
    CGFloat height = [UILabel getSpaceLabelHeight:contentLabel.text withFont:contentLabel.font withWidth:contentLabel.frame.size.width];
    CGRect labelFrame = contentLabel.frame;
    labelFrame.size.height = height;
    [contentLabel setFrame:labelFrame];
    [UILabel setLabelSpace:contentLabel withValue:contentLabel.text withFont:contentLabel.font];
    //线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(contentLabel.frame) + 16, Main_Screen_Width - 50, 1)];
    line.backgroundColor = RGB(245, 245, 245);
    [_myScrollView addSubview:line];
    //地址标签
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(line.frame) + 16, 0, 0)];
    addressLabel.font = SYSTEMFONT(14);
    addressLabel.textColor = RGB(51, 51, 51);
    addressLabel.text = @"地址";
    [addressLabel sizeToFit];
    [_myScrollView addSubview:addressLabel];
    //地址内容
    UILabel *addressValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(addressLabel.frame) + 8, 0, 0)];
    addressValueLabel.font = SYSTEMFONT(14);
    addressValueLabel.textColor = RGB(135, 135, 135);
    addressValueLabel.text = @"武汉市东湖海洋世界风景区";
    [addressValueLabel sizeToFit];
    [_myScrollView addSubview:addressValueLabel];
    //距离
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(addressValueLabel.frame) + 3, 0, 0)];
    distanceLabel.font = SYSTEMFONT(11);
    distanceLabel.textColor = RGB(189, 189, 189);
    distanceLabel.text = @"距离1.2km";
    [distanceLabel sizeToFit];
    [_myScrollView addSubview:distanceLabel];
    //导航按钮
    UIButton *daohangBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 25 - 38, CGRectGetMinY(addressValueLabel.frame), 38, 38)];
    [daohangBtn setImage:[UIImage imageNamed:@"daohang"] forState:UIControlStateNormal];
    [_myScrollView addSubview:daohangBtn];
}

-(void)playVoice{
    
    if ([[Player sharedManager] isPlaying]) {
        DLog(@"停止播放");
//        [self.calloutView.jieshuoBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [[Player sharedManager] stop];
    }else{
        DLog(@"停止播放 重新播放");
        [[Player sharedManager] stop];
//        [self.calloutView.jieshuoBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,[_poiDetails objectForKey:@"voice"]];
        DLog(@"%@",path);
        NSURL *url=[NSURL URLWithString:path];
        [[Player sharedManager] setUrl:url];
        [[Player sharedManager] play];
    }
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
