//
//  FeatureListViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/1/6.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "FeatureListViewController.h"
#import "WTpoi.h"
#import "FeatureTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Player.h"
#import "DetailViewController.h"
#import "JZNavigationExtension.h"
#import "UIImage+Color.h"
#import "FSAudioStream.h"

@interface FeatureListViewController (){
    UIButton *oldPlayBtn;
    long playIndex;
    
    UIView *maskView;
    UIView *popView;
    BOOL popFlag;
    
    UIBarButtonItem *rightSearchItem;
    UIBarButtonItem *rightSearchHighlightItem;
}

@end

@implementation FeatureListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    rightSearchItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(showSearchView)];
    rightSearchHighlightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"searchHighlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(showSearchView)];
    self.navigationItem.rightBarButtonItem = rightSearchItem;
    
    self.jz_navigationBarBackgroundAlpha = 1.f;
    self.jz_wantsNavigationBarVisible = YES;
    
    [self initPopView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"景区热点";
    self.navigationItem.titleView = titleLabel;
    
    [self.mytableview reloadData];
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
}

//初始化弹出视图
-(void)initPopView{
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 0)];
    maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
    maskView.clipsToBounds = YES;
    
    popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Height, 200)];
    popView.backgroundColor = [UIColor whiteColor];
    [maskView addSubview:popView];
    
}

//弹出搜索界面
-(void)showSearchView{
    if (popFlag) {
        popFlag = !popFlag;
        self.navigationItem.rightBarButtonItem = rightSearchItem;
        
        
        [UIView animateWithDuration:0.35 animations:^{
            maskView.frame = CGRectMake(0, 0, Main_Screen_Width, 0);
        } completion:^(BOOL finished){
            [maskView removeFromSuperview];
        }];
        
    }else{
        popFlag = !popFlag;
        self.navigationItem.rightBarButtonItem = rightSearchHighlightItem;
        
        
        maskView.frame = CGRectMake(0, 0, Main_Screen_Width, 0);
        [self.view addSubview:maskView];
        [UIView animateWithDuration:0.35 animations:^{
            maskView.frame = CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height);
        } completion:nil];
    }
}

-(void)playVoiceEnd{
    if (oldPlayBtn) {
        [oldPlayBtn setImage:[UIImage imageNamed:@"js"] forState:UIControlStateNormal];
        playIndex = -1;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playVoiceEnd" object:nil];
}

-(void)playVoice:(UIButton *)btn{
    
    WTPoi *poi = [_jingdianArray objectAtIndex:btn.tag];
    NSString *voice = poi.voice;
    
    if ([[Player sharedManager] isPlaying]) {//当前正在播放
        NSString *playingUrlStr = [[[Player sharedManager] url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,voice];
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            [[Player sharedManager] stop];//先停止播放
            //            btn.titleLabel.text = @"解说";
            //            [btn setTitle:@"解说" forState:UIControlStateNormal];
            
            [btn setImage:[UIImage imageNamed:@"js"] forState:UIControlStateNormal];
            oldPlayBtn = nil;
            playIndex = -1;
        }else{//不是该景点的 重新播放
            [[Player sharedManager] stop];//先停止播放
            //            oldPlayBtn.titleLabel.text = @"解说";
            //            [oldPlayBtn setTitle:@"解说" forState:UIControlStateNormal];
            [oldPlayBtn setImage:[UIImage imageNamed:@"js"] forState:UIControlStateNormal];
            
            [[Player sharedManager] setUrl:[NSURL URLWithString:path]];
            [[Player sharedManager] play];
            //            btn.titleLabel.text = @"暂停";
            //            [btn setTitle:@"暂停" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"zt"] forState:UIControlStateNormal];
            oldPlayBtn = btn;
            playIndex = btn.tag;
        }
    }else{//当前没有播放
        
        if (oldPlayBtn) {
            [oldPlayBtn setImage:[UIImage imageNamed:@"js"] forState:UIControlStateNormal];
            playIndex = -1;
        }
        
        [[Player sharedManager] stop];
        
        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,voice];
        [[Player sharedManager] setUrl:[NSURL URLWithString:path]];
        [[Player sharedManager] play];
        //        btn.titleLabel.text = @"暂停";
        //        [btn setTitle:@"暂停" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"zt"] forState:UIControlStateNormal];
        oldPlayBtn = btn;
        playIndex = btn.tag;
    }
    
    
    //    if ([[Player sharedManager] isPlaying]) {
    //        DLog(@"停止播放");
    //        //        [self.calloutView.jieshuoBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    //        [[Player sharedManager] stop];
    //    }else{
    //        DLog(@"停止播放 重新播放");
    //        [[Player sharedManager] stop];
    //        //        [self.calloutView.jieshuoBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    //        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,voice];
    //        DLog(@"%@",path);
    //        NSURL *url=[NSURL URLWithString:path];
    //        [[Player sharedManager] setUrl:url];
    //        [[Player sharedManager] play];
    //    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
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
    return _jingdianArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 144;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"featureCell";
    FeatureTableViewCell *cell = (FeatureTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell= (FeatureTableViewCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"FeatureTableViewCell" owner:self options:nil]  lastObject];
        //        cell.playBtn.backgroundColor = RGBA(255, 255, 255, 0.5);
        [cell.playBtn setBackgroundImage:[UIImage imageWithColor:RGBA(255, 255, 255, 0.5) size:CGSizeMake(65, 25)] forState:UIControlStateNormal];
        ViewBorderRadius(cell.playBtn, 12.5, 0, [UIColor whiteColor]);
    }
    WTPoi *poi = [_jingdianArray objectAtIndex:indexPath.row];
    DLog(@"%@",poi.image);
    [cell.myImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",poi.image]]];
    cell.name.text = poi.name;
    cell.desLabel.text = @"世界上最多样生态系统的森林，穿行其中绝对是一场极富挑战性的奇幻冒险; 世界上最多样生态系统的森林，穿行其...";
    cell.playBtn.tag = indexPath.row;
    [cell.playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
    
    if (oldPlayBtn != nil && cell.playBtn.tag == playIndex) {
        [cell.playBtn setImage:[UIImage imageNamed:@"zt"] forState:UIControlStateNormal];
    }else{
        [cell.playBtn setImage:[UIImage imageNamed:@"js"] forState:UIControlStateNormal];
    }
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *vc = [[DetailViewController alloc] init];
    WTPoi *poi = [_jingdianArray objectAtIndex:indexPath.row];
    vc.poi = poi;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
