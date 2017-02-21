//
//  AboutViewController.m
//  impi
//
//  Created by Chris on 15/4/20.
//  Copyright (c) 2015年 Zoimedia. All rights reserved.
//

#import "AboutViewController.h"
#import "UILabel+SetLabelSpace.h"

@interface AboutViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *aboutTableView;

@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UILabel *rightsOneLabel;
@property (strong, nonatomic) UILabel *rightsTwoLabel;

@end

@implementation AboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    
    
    _aboutTableView.delegate = self;
    _aboutTableView.dataSource = self;
    
    NSDictionary *infoDict = [[NSBundle mainBundle]infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 250)];
//    tableHeaderView.backgroundColor = RGB(245, 245, 245);
    
    _logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(Main_Screen_Width/2 - 40, 30, 80, 80)];
    [_logoImageView setImage:[UIImage imageNamed:@"flat"]];
//    _logoImageView.layer.cornerRadius = 10;
//    _logoImageView.layer.masksToBounds = YES;
    [tableHeaderView addSubview:_logoImageView];
    
    _versionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, Main_Screen_Width, 25)];
    _versionLabel.text = @"氢旅行";
    _versionLabel.font = [UIFont boldSystemFontOfSize:18];
    _versionLabel.textColor = RGB(67,216,230);
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:_versionLabel];
    
    _rightsOneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, Main_Screen_Width, 20)];
    _rightsOneLabel.font = [UIFont systemFontOfSize:14.f];
    _rightsOneLabel.textColor = RGBA(0, 0, 0, 0.3);
    _rightsOneLabel.text = [NSString stringWithFormat:@"V%@", version];
    _rightsOneLabel.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:_rightsOneLabel];
    
    _rightsTwoLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 180, Main_Screen_Width-32, 21)];
    _rightsTwoLabel.font = [UIFont systemFontOfSize:14.f];
    _rightsTwoLabel.textColor = RGB(102, 102, 102);
    _rightsTwoLabel.text = @"              氢旅行，一款专为游客打造的全新视角体验的探索式景区AR导览工具。";
    _rightsTwoLabel.numberOfLines = 0;
    [tableHeaderView addSubview:_rightsTwoLabel];
    
    CGFloat height = [UILabel getSpaceLabelHeight:_rightsTwoLabel.text withFont:_rightsTwoLabel.font withWidth:Main_Screen_Width-32];
    CGRect labelFrame = _rightsTwoLabel.frame;
    labelFrame.size.height = height;
    [_rightsTwoLabel setFrame:labelFrame];
    
    [UILabel setLabelSpace:_rightsTwoLabel withValue:_rightsTwoLabel.text withFont:_rightsTwoLabel.font];
    
    CGRect frame = tableHeaderView.frame;
    frame.size.height = CGRectGetMaxY(_rightsTwoLabel.frame) + 20;
    [tableHeaderView setFrame:frame];
    
    _aboutTableView.tableHeaderView = tableHeaderView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - Setup Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGB(102, 102, 102);
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"官方微博";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"官方网站";
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"服务协议";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
