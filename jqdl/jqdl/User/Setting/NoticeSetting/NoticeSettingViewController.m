//
//  NoticeSettingViewController.m
//  qlxing
//
//  Created by Stephen Chin on 16/7/26.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "NoticeSettingViewController.h"

@interface NoticeSettingViewController (){
    UISwitch *switch1;
    UISwitch *switch2;
    UISwitch *switch3;
    UISwitch *switch4;
    UISwitch *switch5;
}

@end

@implementation NoticeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _myTableView.backgroundColor = RGB(245, 245, 245);
    
    self.title = @"通知提醒";
    
    switch1 = [[UISwitch alloc] init];
    switch1.tag = 1;
    switch1.onTintColor = RGB(67,216,230);
    switch2 = [[UISwitch alloc] init];
    switch2.tag = 2;
    switch2.onTintColor = RGB(67,216,230);
    switch3 = [[UISwitch alloc] init];
    switch3.tag = 3;
    switch3.onTintColor = RGB(67,216,230);
    switch4 = [[UISwitch alloc] init];
    switch4.tag = 4;
    switch4.onTintColor = RGB(67,216,230);
    switch5 = [[UISwitch alloc] init];
    switch5.tag = 5;
    switch5.onTintColor = RGB(67,216,230);
    
    [switch1 addTarget:self action:@selector(updateNotice:) forControlEvents:UIControlEventValueChanged];
    [switch2 addTarget:self action:@selector(updateNotice:) forControlEvents:UIControlEventValueChanged];
    [switch3 addTarget:self action:@selector(updateNotice:) forControlEvents:UIControlEventValueChanged];
    [switch4 addTarget:self action:@selector(updateNotice:) forControlEvents:UIControlEventValueChanged];
    [switch5 addTarget:self action:@selector(updateNotice:) forControlEvents:UIControlEventValueChanged];
    
    switch1.on = YES;
    switch2.on = YES;
    switch3.on = YES;
    switch4.on = YES;
    switch5.on = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateNotice:(UISwitch *)s{
    DLog(@"%ld %@",s.tag,s.on ? @"yes" : @"no");
}

#pragma mark - <UITableViewDataSource>

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"通知方式";
    }
    if (section == 1) {
        return @"通知类型";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = RGB(102, 102, 102);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"声音提醒";
            cell.accessoryView = switch1;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"震动提醒";
            cell.accessoryView = switch2;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"公告提醒";
            cell.accessoryView = switch3;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"行程提醒";
            cell.accessoryView = switch4;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"私信提醒";
            cell.accessoryView = switch5;
        }
    }
    
    
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if (section == 2) {
//        return 45;
//    }
    return 1;
}

@end
