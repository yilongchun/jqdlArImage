//
//  StoreViewController.m
//  jqdl
//
//  Created by Stephen Chin on 17/1/18.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "StoreViewController.h"
#import "BMAdScrollView.h"
#import "JZNavigationExtension.h"
#import "UILabel+SetLabelSpace.h"
#import "Player.h"
#import <MapKit/MapKit.h>
#import "Util.h"
#import "LCActionSheet.h"
#import "Player.h"
#import "PhotoViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MyPointAnnotation.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "YWRectAnnotationView.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"

@interface StoreViewController ()<LCActionSheetDelegate,FSPCMAudioStreamDelegate,ImageClickEventDelegate,BMKMapViewDelegate>{
    NSArray *maps;
    Player *player;
    UISlider *slider;
    UILabel *startLabel;
    UILabel *timeLabel;
    UIButton *playBtn;
    
    BOOL currentPlay;
    BOOL dragFlag;
    UInt64 end;
    
    NSMutableArray *jdArray;
    UIScrollView *jdScrollView;
}

@end

@implementation StoreViewController
@synthesize storeId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    player = [Player sharedManager];
    player.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.jz_navigationBarBackgroundHidden = NO;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 1.f;
    
    [self loadData];
    
    
}

//进入详情
-(void)toDetail:(UIGestureRecognizer *)recog{
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    
    NSDictionary *dic = [jdArray objectAtIndex:recog.view.tag];
    
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.poi = dic;
    vc.spotId = [dic objectForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

//加载景区详情
-(void)loadData{
    
    [self showHudInView:self.view];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@",kHost,kVERSION,@"/stores/",storeId];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self hideHud];
        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
        DLog(@"%@",dic);
        
        NSNumber *code = [dic objectForKey:@"code"];
        if ([code intValue] == 200) {
            _poi = [dic objectForKey:@"data"];
            [self setContent];
            [self loadRmjd];
        }else{
            [self showHintInView:self.view hint:@"加载失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self hideHud];
        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        if (data) {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            NSString *message = [dic objectForKey:@"message"];
            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
            DLog(@"%@",result);
        }else{
            [self showHintInView:self.view hint:error.localizedDescription];
        }
    }];
    
}

//加载热门景点
-(void)loadRmjd{
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",kHost,kVERSION,@"/stores/",storeId,@"/spots"];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic= [NSDictionary dictionaryWithDictionary:responseObject];
        NSArray *data = [dic objectForKey:@"data"];
        
        if (jdArray == nil) {
            jdArray = [NSMutableArray array];
        }
        
        
        CGFloat x = 18;
        int seq = 0;
        for (int i = 0 ; i < data.count; i++) {
            NSMutableDictionary *spotDic = [[NSMutableDictionary alloc] initWithDictionary:data[i]];
            
            NSNumber *is_public = [spotDic objectForKey:@"is_public"];
            if (![is_public boolValue]) {
                continue;
            }
            NSArray *imagesArr = [spotDic objectForKey:@"images"];
            NSDictionary *image;
            if (imagesArr.count > 0) {
                image = [imagesArr objectAtIndex:0];
            }
            NSString *name = [spotDic objectForKey:@"name"];
            NSString *type = [spotDic objectForKey:@"type"];
            if ([type isEqualToString:@"scenery_spot"]) {
                [jdArray addObject:spotDic];
                
                UIView *jdView = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 141, 120)];
                jdView.tag = seq;
                jdView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
                [jdView addGestureRecognizer:tap];
                ViewBorderRadius(jdView, 0, 1, RGB(242, 242, 242));
                
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 141, 90)];
                [imageview setImageWithURL:[NSURL URLWithString:[image objectForKey:@"url"]]];
                [jdView addSubview:imageview];
                
                UILabel *jdTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 90, 100, 30)];
                jdTitleLabel.font = SYSTEMFONT(11);
                jdTitleLabel.textColor = RGB(51, 51, 51);
                jdTitleLabel.text = name;
                [jdView addSubview:jdTitleLabel];
                
                [jdScrollView addSubview:jdView];
                x = CGRectGetMaxX(jdView.frame) + 18;
                seq++;
            }
            
            [jdScrollView setContentSize:CGSizeMake(x, 120)];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSData *data =[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"];
        if (data) {
            NSString *result  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            NSString *message = [dic objectForKey:@"message"];
            [self showHintInView:self.view hint:NSLocalizedString(message, nil)];
            DLog(@"%@",result);
        }else{
            [self showHintInView:self.view hint:error.localizedDescription];
        }
    }];
    
}

//设置内容
-(void)setContent{
    //顶部广告
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *strArr = [NSMutableArray array];
//    NSArray *images = [[_poi objectForKey:@"images"] componentsSeparatedByString:@","];
//    for (int i = 0 ; i < images.count; i++) {
//        [arr addObject:[images objectAtIndex:i]];
//        [strArr addObject:@"1"];
//    }
    
    NSArray *images = [_poi objectForKey:@"images"];
    for (int i = 0 ; i < images.count; i++) {
        [arr addObject:[[images objectAtIndex:i] objectForKey:@"url"]];
        [strArr addObject:@"1"];
    }
    
    
    BMAdScrollView *adView = [[BMAdScrollView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width, 250) images:arr titles:strArr];
    adView.delegate = self;
    [_myScrollView addSubview:adView];
    //标题
    NSString *slogan = [_poi objectForKey:@"name"];
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
//    titleLabel.font = BOLDSYSTEMFONT(17);
//    titleLabel.textColor = [UIColor blackColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = slogan;
//    self.navigationItem.titleView = titleLabel;
    
    self.title = slogan;
    
    NSDictionary *details = [_poi objectForKey:@"details"];
    NSString *rating = [details objectForKey:@"rating"];
    
    if ([rating isEqualToString:@"2A"]) {
        UIImageView *jTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250 - 19 - 18 + 64, 54, 18)];
        jTypeImage.image = [UIImage imageNamed:@"2a"];
        [_myScrollView addSubview:jTypeImage];
    }else if ([rating isEqualToString:@"3A"]){
        UIImageView *jTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250 - 19 - 18 + 64, 54, 18)];
        jTypeImage.image = [UIImage imageNamed:@"3a"];
        [_myScrollView addSubview:jTypeImage];
    }else if ([rating isEqualToString:@"4A"]){
        UIImageView *jTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250 - 19 - 18 + 64, 54, 18)];
        jTypeImage.image = [UIImage imageNamed:@"4a"];
        [_myScrollView addSubview:jTypeImage];
    }else if ([rating isEqualToString:@"5A"]){
        UIImageView *jTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250 - 19 - 18 + 64, 54, 18)];
        jTypeImage.image = [UIImage imageNamed:@"5a"];
        [_myScrollView addSubview:jTypeImage];
    }
    
    
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
    [sliderBackground addSubview:startLabel];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(sliderBackground.frame) - 35, CGRectGetHeight(sliderBackground.frame) - 15, 34, 15)];
    timeLabel.font = SYSTEMFONT(10);
    timeLabel.textColor = RGB(189, 189, 189);
    [sliderBackground addSubview:timeLabel];
    [_myScrollView addSubview:sliderBackground];
    
    
    NSString *description = [_poi objectForKey:@"description"];
    //文本介绍
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(playBtn.frame) + 20, Main_Screen_Width - 36, 10)];
    contentLabel.numberOfLines = 0;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = RGB(135, 135, 135);
    contentLabel.text = description;
    [contentLabel sizeToFit];
    [_myScrollView addSubview:contentLabel];
    
    CGFloat height = [UILabel getSpaceLabelHeight:description withFont:contentLabel.font withWidth:contentLabel.frame.size.width];
    CGRect labelFrame = contentLabel.frame;
    labelFrame.size.height = height;
    [contentLabel setFrame:labelFrame];
    [UILabel setLabelSpace:contentLabel withValue:description withFont:contentLabel.font];
    
    //景区等级
    UILabel *ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(contentLabel.frame) + 16, 0, 0)];
    ratingLabel.font = SYSTEMFONT(14);
    ratingLabel.textColor = RGB(51, 51, 51);
    ratingLabel.text = @"景区等级";
    [ratingLabel sizeToFit];
    [_myScrollView addSubview:ratingLabel];
    
    UIImageView *ratingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(ratingLabel.frame) + 9, 54, 18)];
    ratingImageView.image = [UIImage imageNamed:@"4a"];
    [_myScrollView addSubview:ratingImageView];
    
    //线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(ratingImageView.frame) + 16, Main_Screen_Width - 36, 1)];
    line.backgroundColor = RGB(245, 245, 245);
    [_myScrollView addSubview:line];
    //地址标签
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(line.frame) + 16, 0, 0)];
    addressLabel.font = SYSTEMFONT(14);
    addressLabel.textColor = RGB(51, 51, 51);
    addressLabel.text = @"地址";
    [addressLabel sizeToFit];
    [_myScrollView addSubview:addressLabel];
    //地址内容
    UILabel *addressValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addressLabel.frame) + 10, CGRectGetMinY(addressLabel.frame), 0, 0)];
    addressValueLabel.font = SYSTEMFONT(14);
    addressValueLabel.textColor = RGB(135, 135, 135);
    addressValueLabel.text = [_poi objectForKey:@"address"];
    [addressValueLabel sizeToFit];
    [_myScrollView addSubview:addressValueLabel];
    
    
    
    //地图
    BMKMapView *map = [[BMKMapView alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(addressValueLabel.frame) + 16, Main_Screen_Width - 36, 130)];
    map.delegate = self;
//    map.gesturesEnabled = NO;
    [map setZoomLevel:15];
    [_myScrollView addSubview:map];
    
    //添加PointAnnotation
    MyPointAnnotation* annotation = [[MyPointAnnotation alloc]init];
    
    
    NSArray *coordinates = [_poi objectForKey:@"coordinates"];
    NSNumber *lat = coordinates[0];
    NSNumber *lng = coordinates[1];
//    CLLocationCoordinate2D coo = CLLocationCoordinate2DMake(30.735277777777778,111.31583333333333);
    CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coo,BMK_COORDTYPE_GPS);
    CLLocationCoordinate2D coor = BMKCoorDictionaryDecode(testdic);
    
    annotation.coordinate = coor;
//    annotation.title = [_poi objectForKey:@"name"];
    annotation.poi = _poi;
    annotation.pointCalloutInfo = _poi;
    [map addAnnotation:annotation];
    [map selectAnnotation:annotation animated:YES];
    [map setCenterCoordinate:coor animated:YES];
    
    UIButton *daohangBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(map.frame)/2 - 83 - 24, CGRectGetHeight(map.frame)/2-17, 83, 34)];
    [daohangBtn setImage:[UIImage imageNamed:@"daohang2"] forState:UIControlStateNormal];
    [daohangBtn addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
    [map addSubview:daohangBtn];
    
    
//    line = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(map.frame) + 16, Main_Screen_Width - 50, 1)];
//    line.backgroundColor = RGB(245, 245, 245);
//    [_myScrollView addSubview:line];
//    
//    //电话
//    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(line.frame) + 16, 0, 0)];
//    phoneLabel.font = SYSTEMFONT(14);
//    phoneLabel.textColor = RGB(51, 51, 51);
//    phoneLabel.text = @"电话";
//    [phoneLabel sizeToFit];
//    [_myScrollView addSubview:phoneLabel];
//    
//    UILabel *phoneValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(phoneLabel.frame) + 10, CGRectGetMinY(phoneLabel.frame), 0, 0)];
//    phoneValueLabel.font = SYSTEMFONT(14);
//    phoneValueLabel.textColor = RGB(135, 135, 135);
//    phoneValueLabel.text = [[_poi objectForKey:@"address"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [phoneValueLabel sizeToFit];
//    [_myScrollView addSubview:phoneValueLabel];
//    
//    line = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(phoneLabel.frame) + 16, Main_Screen_Width - 50, 1)];
//    line.backgroundColor = RGB(245, 245, 245);
//    [_myScrollView addSubview:line];
//    
//    //门票价格
//    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(line.frame) + 16, 0, 0)];
//    priceLabel.font = SYSTEMFONT(14);
//    priceLabel.textColor = RGB(51, 51, 51);
//    priceLabel.text = @"门票价格";
//    [priceLabel sizeToFit];
//    [_myScrollView addSubview:priceLabel];
//    
//    UILabel *priceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(priceLabel.frame) + 10, CGRectGetMinY(priceLabel.frame), 0, 0)];
//    priceValueLabel.font = SYSTEMFONT(14);
//    priceValueLabel.textColor = RGB(135, 135, 135);
//    priceValueLabel.text = [[_poi objectForKey:@"address"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [priceValueLabel sizeToFit];
//    [_myScrollView addSubview:priceValueLabel];
    
    
    //全景游览
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(map.frame) + 20, Main_Screen_Width, 1)];
    line.backgroundColor = RGB(240, 240, 240);
    [_myScrollView addSubview:line];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), Main_Screen_Width, 10)];
    sepView.backgroundColor = RGB(245, 245, 245);
    [_myScrollView addSubview:sepView];
    
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sepView.frame), Main_Screen_Width, 1)];
    line.backgroundColor = RGB(240, 240, 240);
    [_myScrollView addSubview:line];
    
    UILabel *qjylLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(line.frame) + 16, 0, 0)];
    qjylLabel.font = BOLDSYSTEMFONT(14);
    qjylLabel.textColor = RGB(51, 51, 51);
    qjylLabel.text = @"全景导览";
    [qjylLabel sizeToFit];
    [_myScrollView addSubview:qjylLabel];
    
    UIView *vrView = [[UIView alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(qjylLabel.frame) + 16, Main_Screen_Width - 36, 140)];
    vrView.backgroundColor = [UIColor grayColor];
    [_myScrollView addSubview:vrView];
    
    //热门景点
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(vrView.frame) + 20, Main_Screen_Width, 1)];
    line.backgroundColor = RGB(240, 240, 240);
    [_myScrollView addSubview:line];
    
    sepView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame), Main_Screen_Width, 10)];
    sepView.backgroundColor = RGB(245, 245, 245);
    [_myScrollView addSubview:sepView];
    
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sepView.frame), Main_Screen_Width, 1)];
    line.backgroundColor = RGB(240, 240, 240);
    [_myScrollView addSubview:line];
    
    UILabel *rmjdLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(line.frame) + 16, 0, 0)];
    rmjdLabel.font = BOLDSYSTEMFONT(14);
    rmjdLabel.textColor = RGB(51, 51, 51);
    rmjdLabel.text = @"热门景点";
    [rmjdLabel sizeToFit];
    [_myScrollView addSubview:rmjdLabel];
    
    jdScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(rmjdLabel.frame) + 16, Main_Screen_Width, 120)];
    jdScrollView.showsHorizontalScrollIndicator = NO;
    [_myScrollView addSubview:jdScrollView];
    
    
    
    [_myScrollView setContentSize:CGSizeMake(Main_Screen_Width, CGRectGetMaxY(jdScrollView.frame) + 30)];
    
    //距离
    //    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(addressValueLabel.frame) + 3, 0, 0)];
    //    distanceLabel.font = SYSTEMFONT(11);
    //    distanceLabel.textColor = RGB(189, 189, 189);
    //    distanceLabel.text = @"距离1.2km";
    //    [distanceLabel sizeToFit];
    //    [_myScrollView addSubview:distanceLabel];
    //导航按钮
//    UIButton *daohangBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 25 - 38, CGRectGetMinY(addressValueLabel.frame), 38, 38)];
//    [daohangBtn setImage:[UIImage imageNamed:@"daohang"] forState:UIControlStateNormal];
//    [daohangBtn addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
//    [_myScrollView addSubview:daohangBtn];
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
    
    NSArray *audio_clips = [_poi objectForKey:@"audio_clips"];
    NSString *path;
    if (audio_clips.count > 0) {
        path = [audio_clips[0] objectForKey:@"url"];
    }
    if (player.audioState == kFsAudioStreamPlaying) {
        NSString *playingUrlStr = [[player url] absoluteString];        
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            DLog(@"播放的地址一致");
            currentPlay = YES;
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
    dragFlag = YES;
}

-(void)sliderValueChanged:(UISlider *)sender{
    dragFlag = NO;
    if (end > 0) {
        if (player.audioState == kFsAudioStreamPlaying || player.audioState == kFsAudioStreamPaused || player.audioState == kFsAudioStreamRetryingSucceeded) {
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
    [player setUrl:nil];
    [playBtn setImage:[UIImage imageNamed:@"playStart"] forState:UIControlStateNormal];
    [slider setValue:0.0 animated:YES];
    startLabel.text = @"00:00";
}

//语音播放
-(void)playVoice{
    NSArray *audio_clips = [_poi objectForKey:@"audio_clips"];
    NSString *path;
    if (audio_clips.count > 0) {
        path = [audio_clips[0] objectForKey:@"url"];
    }
    
    currentPlay = YES;
    if (player.audioState == kFsAudioStreamPlaying) {
        NSString *playingUrlStr = [[player url] absoluteString];
        
        
        if (![playingUrlStr isEqualToString:path]) {
            [player stop];
            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
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
        }
    }
    else if (player.audioState == kFsAudioStreamPaused){
        [player pause];
        
        if ([player isPlaying]) {
            DLog(@"isPlaying");
            [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        }else{
            DLog(@"notPlaying");
            [playBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
        }
    }else{
        [playBtn setImage:[UIImage imageNamed:@"ztbf"] forState:UIControlStateNormal];
        NSURL *url=[NSURL URLWithString:path];
        [player setUrl:url];
        [player play];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    player.delegate = self;
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
    if (!dragFlag && currentPlay) {
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
        NSArray *coordinates = [_poi objectForKey:@"coordinates"];
        NSNumber *lat = coordinates[0];
        NSNumber *lng = coordinates[1];
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([lat doubleValue],[lng doubleValue]);//纬度，经度
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
    
    
    NSMutableArray *arr = [NSMutableArray array];
   
    NSArray *images = [_poi objectForKey:@"images"];
    for (int i = 0 ; i < images.count; i++) {
        [arr addObject:[[images objectAtIndex:i] objectForKey:@"url"]];
        
    }
    if (arr.count > 0) {
        PhotoViewController *vc = [[PhotoViewController alloc] init];
        vc.images = arr;
        vc.name = [_poi objectForKey:@"name"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - BMKMapViewDelegate

// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MyPointAnnotation class]]) {
        
//        MyPointAnnotation *anno = (MyPointAnnotation *)annotation;
//        NSDictionary *poi = anno.poi;
        
        BMKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        if (view == nil) {
            view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        view.image = [UIImage imageNamed:@"storeLocation"];
        
//        YWRectAnnotationView *view =(YWRectAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotation"];
//        if (view==nil)
//        {
//            view=[[ YWRectAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        }
//        UIImage *leftImage = [UIImage imageNamed:@"store4"];
//        UIImage *leftHighligntImage = [UIImage imageNamed:@"store5"];
//       
//        view.leftHighlightImage = leftHighligntImage;
//        [view setTitleText:[poi objectForKey:@"name"] leftImage:leftImage];
        return view;
    }
    
    return nil;
}
@end
