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
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(Main_Screen_Width/2 - 50, 64 + 30, 100, 100)];
    imageview.image = [UIImage imageNamed:@"mask"];
    [self.view addSubview:imageview];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"鳐鱼";
    label.textColor = RGB(51, 51, 51);
    label.font = [UIFont systemFontOfSize:23];
    [label sizeToFit];
    [label setFrame:CGRectMake(Main_Screen_Width/2 - CGRectGetWidth(label.frame)/2, CGRectGetMaxY(imageview.frame) + 30, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
    [self.view addSubview:label];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(label.frame) + 30, 0, 0)];
    label2.text = @"出现地点:";
    label2.textColor = RGB(51, 51, 51);
    label2.font = SYSTEMFONT(14);
    [label2 sizeToFit];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label2.frame) + 14, CGRectGetMinY(label2.frame), 0, 0)];
    label3.text = @"海底隧道";
    label3.textColor = RGB(135, 135, 135);
    label3.font = SYSTEMFONT(14);
    [label3 sizeToFit];
    [self.view addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(label2.frame) + 10, 0, 0)];
    label4.text = @"所属景区:";
    label4.textColor = RGB(51, 51, 51);
    label4.font = SYSTEMFONT(14);
    [label4 sizeToFit];
    [self.view addSubview:label4];
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label4.frame) + 14, CGRectGetMinY(label4.frame), 0, 0)];
    label5.text = @"东湖海洋世界景区";
    label5.textColor = RGB(135, 135, 135);
    label5.font = SYSTEMFONT(14);
    [label5 sizeToFit];
    [self.view addSubview:label5];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(label4.frame) + 20, Main_Screen_Width - 64, 1)];
    line.backgroundColor = RGBA(103, 103, 103, 0.1);
    [self.view addSubview:line];
    
    
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(line.frame) + 20, Main_Screen_Width - 64, 0)];
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
