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

#import <MapKit/MapKit.h>
#import "Util.h"
#import "LCActionSheet.h"
#import "PhotoViewController.h"

@interface DetailViewController ()<LCActionSheetDelegate,FSPCMAudioStreamDelegate,ImageClickEventDelegate>{
//    UIButton *jieshuoBtn;
    NSArray *maps;
    Player *player;
//    UIProgressView *progress;
    UISlider *slider;
    UILabel *startLabel;
    UILabel *timeLabel;
    UIButton *playBtn;
    
    
    BOOL dragFlag;
    UInt64 end;
}

@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    player = [Player sharedManager];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
//    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"shoucang"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(shoucang)];
//    UIBarButtonItem *rightItem2 = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(share)];
//    
//    self.navigationItem.rightBarButtonItems = @[rightItem2,rightItem1];
    
//    self.navigationController.navigationBar.translucent = YES;
    self.jz_navigationBarBackgroundHidden = NO;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 1.f;
        
    [self setContent];
    
//    __weak typeof (self) weakSelf = self;
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//    }
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    
}

//-(void)shoucang{
//    
//}
//
//-(void)share{
//    
//}

//-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
//    
//    if([touch.view isKindOfClass:[UISlider class]]){
//        DLog(@"NO");
//        return NO;
//    
//    }else{
//        DLog(@"YES");
//        return YES;
//    }
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
    
    BMAdScrollView *adView = [[BMAdScrollView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, 250) images:arr titles:strArr];
    adView.delegate = self;
    [_myScrollView addSubview:adView];
//    //标题
    NSString *slogan = [[_poi objectForKey:@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    UILabel *titleLabel = [UILabel new];
//    CGRect titleRect = CGRectMake(20, 210 - 17 - 20, Main_Screen_Width - 50, 30);
//    [titleLabel setFrame:titleRect];
//    titleLabel.backgroundColor =[UIColor clearColor];
//    titleLabel.text = slogan;
//    titleLabel.font = [UIFont systemFontOfSize:17];
//    titleLabel.textColor=[UIColor whiteColor];
//    [_myScrollView addSubview:titleLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = slogan;
    self.navigationItem.titleView = titleLabel;
    
    
    UIImageView *jTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250 - 19 - 17 + 64, 52, 17)];
    jTypeImage.image = [UIImage imageNamed:@"jType1"];
    [_myScrollView addSubview:jTypeImage];
    
    
//    //解说按钮
//    jieshuoBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(adView.frame) + 10, 88, 25)];
//    [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
//    [jieshuoBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
//    [_myScrollView addSubview:jieshuoBtn];
//    
//    progress= [[UIProgressView alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(jieshuoBtn.frame) + 12, Main_Screen_Width - 50, 38)];
//    [progress setProgressViewStyle:UIProgressViewStyleDefault];
//    [_myScrollView addSubview:progress];
    
    UILabel *playTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(adView.frame) + 16, 0, 0)];
    playTitleLabel.font = BOLDSYSTEMFONT(14);
    playTitleLabel.textColor = RGB(51, 51, 51);
    playTitleLabel.text = @"语音导览";
    [playTitleLabel sizeToFit];
    [_myScrollView addSubview:playTitleLabel];
    
    //播放
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(playTitleLabel.frame) + 16, 40, 40)];
    [playBtn setImage:[UIImage imageNamed:@"playStart"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [_myScrollView addSubview:playBtn];
    
    UIImageView *sliderBackground = [[UIImageView alloc] initWithFrame:CGRectMake(67, CGRectGetMaxY(playTitleLabel.frame) + 16, Main_Screen_Width - 67 - 18, 40)];
    sliderBackground.image = [UIImage imageNamed:@"sliderBroudground"];
    slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(sliderBackground.frame) - 20, CGRectGetHeight(sliderBackground.frame) - 10)];
    slider.userInteractionEnabled = YES;
    slider.minimumTrackTintColor = RGB(244, 173, 0);
    slider.maximumTrackTintColor = RGB(227, 227, 227);
    slider.thumbTintColor = RGB(244, 173, 0);
    [slider setThumbImage:[UIImage imageNamed:@"sliderImage"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"sliderImage"] forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    sliderBackground.userInteractionEnabled = YES;
    [sliderBackground addSubview:slider];
    
    startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(sliderBackground.frame) - 15, 34, 15)];
    startLabel.font = SYSTEMFONT(10);
    startLabel.textColor = RGB(189, 189, 189);
    startLabel.text = @"00:00";
    [sliderBackground addSubview:startLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(sliderBackground.frame) - 35, CGRectGetHeight(sliderBackground.frame) - 15, 34, 15)];
    timeLabel.font = SYSTEMFONT(10);
    timeLabel.textColor = RGB(189, 189, 189);
    [sliderBackground addSubview:timeLabel];
    [_myScrollView addSubview:sliderBackground];
    
    //文本介绍
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(playBtn.frame) + 20, Main_Screen_Width - 50, 10)];
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
    addressLabel.text = @"位置";
    [addressLabel sizeToFit];
    [_myScrollView addSubview:addressLabel];
    //地址内容
    UILabel *addressValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addressLabel.frame) + 10, CGRectGetMinY(addressLabel.frame), 0, 0)];
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

    
    if (player.audioState == kFsAudioStreamPlaying) {
        NSString *playingUrlStr = [[player url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            DLog(@"播放的地址一致");
            player.delegate = self;
            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        }else{//不是该景点的 重新播放
            DLog(@"播放的地址不一致");
            [playBtn setImage:[UIImage imageNamed:@"playStart"] forState:UIControlStateNormal];
        }
    }else if (player.audioState == kFsAudioStreamStopped){
        
    }else if (player.audioState == kFsAudioStreamPaused){
        [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
    }
}

-(void)sliderTouchDown{
    DLog(@"sliderTouchDown");
    dragFlag = YES;
}

-(void)sliderValueChanged:(UISlider *)sender{
    dragFlag = NO;
    if (end > 0) {
        if (player.audioState == kFsAudioStreamPlaying || player.audioState == kFsAudioStreamPaused) {
            [player stop];
            FSSeekByteOffset offset;
            offset.position = sender.value;
            offset.start = sender.value * end;
            offset.end = end;
            [player playFromOffset:offset];
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

//播放完成
-(void)playVoiceEnd{
//    [jieshuoBtn setImage:[UIImage imageNamed:@"ypjs"] forState:UIControlStateNormal];
    [player setUrl:nil];
    [playBtn setImage:[UIImage imageNamed:@"playStart"] forState:UIControlStateNormal];
    [slider setValue:0.0 animated:YES];
    startLabel.text = @"00:00";
}

//开始播放
-(void)playVoice{
    
    DLog(@"playVoice audioState %d",player.audioState);
    
    
    
    player.delegate = self;
    if (player.audioState == kFsAudioStreamPlaying) {
        NSString *playingUrlStr = [[player url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        if (![playingUrlStr isEqualToString:path]) {
            [player stop];
            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
            NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
            NSURL *url=[NSURL URLWithString:path];
            [player setUrl:url];
            [player play];
        }else{
            [player pause];
            if ([player isPlaying]) {
                DLog(@"isPlaying");
                [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
            }else{
                DLog(@"notPlaying");
                [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
            }
//            player.audioState = kFsAudioStreamPaused;
        }
    }else if (player.audioState == kFsAudioStreamStopped || player.audioState == kFsAudioStreamRetrievingURL){
        [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
        NSURL *url=[NSURL URLWithString:path];
        [player setUrl:url];
        [player play];
        
        
    }else if (player.audioState == kFsAudioStreamPaused){
        [player pause];
        
        if ([player isPlaying]) {
            DLog(@"isPlaying");
            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        }else{
            DLog(@"notPlaying");
            [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
        }
    }
    
    
    
    
//    NSString *playingUrlStr = [[player url] absoluteString];
//    NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
//    if (![playingUrlStr isEqualToString:path]) {
//        [player stop];
//        [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
//        NSURL *url=[NSURL URLWithString:path];
//        [player setUrl:url];
//        [player play];
//        player.delegate = self;
//    }else{
//        [player pause];
//        
//        if ([player isPlaying]) {
//            DLog(@"isPlaying");
//            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//        }else{
//            DLog(@"notPlaying");
//            [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
//        }
//    }
    
    
    
    
    
    
//    [player pause];
//    
//    if ([player isPlaying]) {
//        DLog(@"isPlaying");
//    }else{
//        DLog(@"notPlaying");
//    }
    
    
    if ([player isPlaying]) {
//        NSString *playingUrlStr = [[player url] absoluteString];
//        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
//        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
//            
//            [player pause];
//
//            if ([player isPlaying]) {
//                DLog(@"isPlaying");
//                [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//            }else{
//                DLog(@"notPlaying");
//                [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
//            }
        
//            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//        }else{//不是该景点的 重新播放
//            [player stop];
//            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//            NSURL *url=[NSURL URLWithString:path];
//            [player setUrl:url];
//            [player play];
            
//            FSSeekByteOffset offset;
//            offset.position = 0.5;
//            [player playFromOffset:offset];
            
//            DLog(@"停止播放 重新播放");
//        }
    }else{
//        DLog(@"播放");
//        [player stop];
//        [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
//        NSString *path = [NSString stringWithFormat:@"%@",[_poi objectForKey:@"voice"]];
//        DLog(@"%@",path);
//        NSURL *url=[NSURL URLWithString:path];
//        [player setUrl:url];
//        [player play];
        
//        FSSeekByteOffset offset;
//        offset.position = 0.5;
//        offset.start = 500000;
//        offset.end = 1144025;
//        [player playFromOffset:offset];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    player.delegate = nil;
    player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playVoiceEnd" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FSPCMAudioStreamDelegate

- (void)audioStream:(FSAudioStream *)audioStream samplesAvailable:(const int16_t *)samples count:(NSUInteger)count{
//    DLog(@"position:%f minutes:%d second:%d minutes:%d second:%d",audioStream.currentTimePlayed.position,audioStream.currentTimePlayed.minute,audioStream.currentTimePlayed.second,audioStream.duration.minute,audioStream.duration.second);
    //    DLog(@"%f %llu %llu",audioStream.currentSeekByteOffset.position,audioStream.currentSeekByteOffset.start,audioStream.currentSeekByteOffset.end);
//    [progress setProgress:audioStream.currentTimePlayed.position animated:YES];
    if (!dragFlag) {
        [slider setValue:audioStream.currentTimePlayed.position animated:YES];
    }
    

    
    end = audioStream.currentSeekByteOffset.end;
    
    startLabel.text = [NSString stringWithFormat:@"%02d:%02d",audioStream.currentTimePlayed.minute,audioStream.currentTimePlayed.second];
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",audioStream.duration.minute,audioStream.duration.second];
    
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

#pragma mark - ImageClickEventDelegate

-(void)imageClickAt:(NSInteger)vid{
    NSString *imageStr = [_poi objectForKey:@"images"];
    if (imageStr != nil) {
        NSArray *images = [imageStr componentsSeparatedByString:@","];
        PhotoViewController *vc = [[PhotoViewController alloc] init];
        vc.images = images;
        vc.name = [_poi objectForKey:@"name"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
