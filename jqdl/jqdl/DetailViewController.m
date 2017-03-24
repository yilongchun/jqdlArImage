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
#import <MapKit/MapKit.h>
#import "Util.h"
#import "LCActionSheet.h"


@interface DetailViewController ()<LCActionSheetDelegate,FSPCMAudioStreamDelegate>{
    UIButton *jieshuoBtn;
    NSArray *maps;
    Player *player;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (player == nil) {
        player = [Player sharedManager];
        player.delegate = self;
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
//    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"shoucang"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(shoucang)];
//    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(share)];
//    
//    self.navigationItem.rightBarButtonItems = @[rightItem2,rightItem1];
    
    self.navigationController.navigationBar.translucent = YES;
    self.jz_navigationBarBackgroundHidden = YES;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 0.f;
        
    [self setContent];
}

//-(void)shoucang{
//    
//}
//
//-(void)share{
//    
//}

//设置内容
-(void)setContent{
    //顶部广告
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *strArr = [NSMutableArray array];
    NSString *imageStr = [_poi objectForKey:@"images"];
    if (imageStr != nil) {
        NSArray *images = [imageStr componentsSeparatedByString:@","];
        for (int i = 0 ; i < images.count; i++) {
            [arr addObject:[images objectAtIndex:i]];
            [strArr addObject:@"1"];
        }
    }
    
    
    BMAdScrollView *adView = [[BMAdScrollView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 250) images:arr titles:strArr];
    [_myScrollView addSubview:adView];
    //标题
    NSString *slogan = [[_poi objectForKey:@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    UILabel *titleLabel = [UILabel new];
    CGRect titleRect = CGRectMake(15, 210, Main_Screen_Width - 50, 30);
    [titleLabel setFrame:titleRect];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.text = slogan;
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor=[UIColor whiteColor];
    [_myScrollView addSubview:titleLabel];
    //解说按钮
    jieshuoBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(adView.frame) + 10, 88, 25)];
    [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
    [jieshuoBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [_myScrollView addSubview:jieshuoBtn];
    //文本介绍
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(jieshuoBtn.frame) + 12, Main_Screen_Width - 50, 10)];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = RGB(135, 135, 135);
    contentLabel.text = [[_poi objectForKey:@"description"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    addressValueLabel.text = [[_poi objectForKey:@"address"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [addressValueLabel sizeToFit];
    [_myScrollView addSubview:addressValueLabel];
    //距离
//    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(addressValueLabel.frame) + 3, 0, 0)];
//    distanceLabel.font = SYSTEMFONT(11);
//    distanceLabel.textColor = RGB(189, 189, 189);
//    distanceLabel.text = @"距离1.2km";
//    [distanceLabel sizeToFit];
//    [_myScrollView addSubview:distanceLabel];
    //导航按钮
    UIButton *daohangBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 25 - 38, CGRectGetMinY(addressValueLabel.frame), 38, 38)];
    [daohangBtn setImage:[UIImage imageNamed:@"daohang"] forState:UIControlStateNormal];
    [daohangBtn addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
    [_myScrollView addSubview:daohangBtn];
    
    [_myScrollView setContentSize:CGSizeMake(Main_Screen_Width, CGRectGetMaxY(daohangBtn.frame) + 50)];
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
    
    //控制播放按钮
    if ([[Player sharedManager] isPlaying]) {
        NSString *playingUrlStr = [[[Player sharedManager] url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            [jieshuoBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        }else{//不是该景点的 重新播放
            [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
        }
        
    }
}

-(void)daohang{
    
    
//    DLog(@"%f %f",_poi.location.coordinate.latitude,_poi.location.coordinate.longitude);
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([[_poi objectForKey:@"latitude"] floatValue],[[_poi objectForKey:@"longitude"] floatValue]);//纬度，经度
    if (maps == nil) {
        maps = [Util getInstalledMapAppWithEndLocation:coords];
    }
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"苹果地图", nil];
//    otherButtonTitles:@"使用AR实景(近距离步行)", nil];
    
    for (int i = 0; i < maps.count; i++) {
        [actionSheet appendButtonTitles:[maps[i] objectForKey:@"title"], nil];
    }
    
    actionSheet.buttonColor        = RGB(67,216,230);
    actionSheet.buttonFont         = [UIFont systemFontOfSize:14.0f];
    actionSheet.destructiveButtonIndexSet = [NSSet setWithObjects:@0, nil];
    actionSheet.destructiveButtonColor    = RGB(178, 178, 178);
    actionSheet.buttonHeight       = 52.0f;
    actionSheet.darkOpacity        = 0.5f;
    [actionSheet show];
}

-(void)playVoiceEnd{
    [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
}

//语音播放
-(void)playVoice{
    if ([player isPlaying]) {
        NSString *playingUrlStr = [[player url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
            [player stop];
            DLog(@"停止播放");
        }else{//不是该景点的 重新播放            
            [player stop];
            [jieshuoBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
            NSURL *url=[NSURL URLWithString:path];
            [player setUrl:url];
            [player play];
            DLog(@"停止播放 重新播放");
        }
    }else{
        DLog(@"播放");
        [player stop];
        [jieshuoBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        DLog(@"%@",path);
        NSURL *url=[NSURL URLWithString:path];
        [player setUrl:url];
        [player play];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playVoiceEnd" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FSPCMAudioStreamDelegate

- (void)audioStream:(FSAudioStream *)audioStream samplesAvailable:(const int16_t *)samples count:(NSUInteger)count{
    DLog(@"position:%f minutes:%d second:%d minutes:%d second:%d",audioStream.currentTimePlayed.position,audioStream.currentTimePlayed.minute,audioStream.currentTimePlayed.second,audioStream.duration.minute,audioStream.duration.second);
    
    
    
    
}

#pragma mark - LCActionSheet Delegate

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex == 0) {//取消
        
    }
//    else if (buttonIndex == 1){//AR
//        
//    }
    else if (buttonIndex == 1){//苹果
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([[_poi objectForKey:@"latitude"] floatValue],[[_poi objectForKey:@"longitude"] floatValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coords addressDictionary:nil];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = [[_poi objectForKey:@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }else{
        NSDictionary *dic = maps[buttonIndex-2];
        NSString *urlString = dic[@"url"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

@end
