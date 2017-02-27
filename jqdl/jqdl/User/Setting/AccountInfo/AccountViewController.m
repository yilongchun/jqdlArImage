//
//  AccountViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/2/8.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "AccountViewController.h"
#import "ForgetPwdViewController.h"
#import "AccountTableViewCell.h"

#import "ValidatePhoneViewController.h"

@interface AccountViewController (){
    NSString *phone;
}

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"账户信息";
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [ud objectForKey:LOGINED_USER];
    if (userInfo) {
        phone = [userInfo objectForKey:@"phone"];
        [_myTableView reloadData];
    }
    
    
}

//修改手机号码
-(void)toUpdatePhone{
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    
    ValidatePhoneViewController *vc = [[ValidatePhoneViewController alloc] init];
//    UpdatePhoneViewController *vc = [[UpdatePhoneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

#pragma mark - Setup Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            static NSString *CellIdentifier = @"accountTableViewCell";
            AccountTableViewCell *cell = (AccountTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil){
                cell= (AccountTableViewCell *)[[[NSBundle  mainBundle] loadNibNamed:@"AccountTableViewCell" owner:self options:nil]  lastObject];
                [cell.updateBtn addTarget:self action:@selector(toUpdatePhone) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (phone.length > 10) {
                
                NSString *p = [NSString stringWithFormat:@"%@****%@",[phone substringWithRange:NSMakeRange(0, 3)],[phone substringWithRange:NSMakeRange(7, 4)]];
                cell.phoneLabel.text = p;
            }
            
            return cell;
        }
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"修改密码";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = RGB(102, 102, 102);
        }
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        label.text = @"     手机号绑定";
        label.textColor = RGB(102, 102, 102);
        label.font = SYSTEMFONT(11);
        return label;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ForgetPwdViewController *vc = [[ForgetPwdViewController alloc] init];
            vc.backToRoot = NO;
            [self.navigationController pushViewController:vc animated:YES];
            vc.title = @"修改密码";
        }
    }
    
}


@end
