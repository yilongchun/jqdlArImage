//
//  UserCenterViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/2/4.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "UserCenterViewController.h"
#import "UIViewController+JZExtension.h"
#import "UIImageView+AFNetworking.h"
#import "SettingViewController.h"
#import "UserInfoViewController.h"

@interface UserCenterViewController (){
    UILabel *nameLabel;
    UIImageView *headBackImageView;
    UIImageView *headImageView;
}

@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.jz_navigationBarBackgroundAlpha = 0;
    self.jz_navigationBarBackgroundHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserInfo) name:@"loadUserCenterInfo" object:nil];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navi_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(dissMissView)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.mytableview.tableFooterView = [[UIView alloc] init];
    
    
    self.mytableview.backgroundColor = RGB(240, 240, 240);
    
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 272)];
    headBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 272)];
    [tableHeaderView addSubview:headBackImageView];
    
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 272)];
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [effectView setEffect:effect];
    [tableHeaderView addSubview:effectView];
    
    headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Main_Screen_Width - 80)/2, 67, 80, 80)];
    ViewBorderRadius(headImageView, 40, 1, [UIColor whiteColor]);
    [effectView.contentView addSubview:headImageView];
    
    
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headImageView.frame) + 14, Main_Screen_Width, 22)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor =[UIColor whiteColor];
    nameLabel.font = BOLDSYSTEMFONT(16);
    
    [effectView.contentView addSubview:nameLabel];
    
//    [headBackImageView setImageWithURL:[NSURL URLWithString:@""]];
//    [headImageView setImageWithURL:[NSURL URLWithString:@""]];
    
    
    
    headImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toUserInfo)];
    [headImageView addGestureRecognizer:tap];
    
    self.mytableview.tableHeaderView = tableHeaderView;
    [self.mytableview reloadData];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Main_Screen_Height - 40 - 20, Main_Screen_Width, 20)];
    tipsLabel.text = @"氢旅行 探索景区新玩法!";
    tipsLabel.textColor = RGB(189, 189, 189);
    tipsLabel.font = SYSTEMFONT(12);
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLabel];
    
    [self loadUserInfo];
}

-(void)loadUserInfo{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [ud objectForKey:LOGINED_USER];
    
    NSString *name = [userInfo objectForKey:@"nickname"];
    nameLabel.text = name;
    
    if (userInfo != nil) {
        NSString *avatar = [userInfo objectForKey:@"avatar"];
        if (![avatar isEqualToString:@""]) {
            [headBackImageView setImageWithURL:[NSURL URLWithString:avatar]];
            [headImageView setImageWithURL:[NSURL URLWithString:avatar]];
        }else{
            headBackImageView.image = [UIImage imageNamed:@"member_no.gif"];
            headImageView.image = [UIImage imageNamed:@"member_no.gif"];
        }
    }
}


//个人信息
-(void)toUserInfo{
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.title = @"个人信息";
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

-(void)dissMissView{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGB(102, 102, 102);
    }
//    if (indexPath.row == 0) {
//        cell.imageView.image = [UIImage imageNamed:@"icon_shoucangdian"];
//        cell.textLabel.text = @"收藏点";
//    }
//    if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"icon_setting"];
        cell.textLabel.text = @"设置";
//    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.row == 1) {
        UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
        UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
        [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
        self.navigationItem.backBarButtonItem = backItem;
        
        SettingViewController *vc = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
//    }
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

@end
