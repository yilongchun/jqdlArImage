//
//  TrackerResultViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/1/5.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "TrackerResultViewController.h"
#import "JZNavigationExtension.h"
#import "UILabel+SetLabelSpace.h"

@interface TrackerResultViewController ()

@end

@implementation TrackerResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.jz_navigationBarBackgroundHidden = NO;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 1.f;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"识别结果";
    self.navigationItem.titleView = titleLabel;
    
    [self setContent];
}

-(void)setContent{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 64 + 25, Main_Screen_Width - 50, 0)];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = RGB(135, 135, 135);
    contentLabel.font = SYSTEMFONT(14);
    contentLabel.text = @"属于软骨鱼纲鳐形目 Rajiformes和鲼形鱼目，是多种扁体软骨鱼的统称。分布于全世界大部分水区，从包括2亚目，共8科约49属315种。中国产6科8属28种。我国各地俗称不一，舟山渔民称黄貂鳐叫黄虎，称蝠鲼叫燕子花鱼、黑虎、双头花鱼，称何氏鳐叫猫猫花鱼，而胶东渔民则叫劳子鱼、老板鱼。鳐鱼体型大小各异，小鳐成体仅50厘米，大鳐可长达8米。鳐鱼无害，底栖，常常部分埋于水底沙中。";
    [self.view addSubview:contentLabel];
//    CGFloat height = [UILabel getSpaceLabelHeight:contentLabel.text withFont:contentLabel.font withWidth:CGRectGetWidth(contentLabel.frame)];
    
    [UILabel setLabelSpace:contentLabel withValue:contentLabel.text withFont:contentLabel.font];
    [contentLabel sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
