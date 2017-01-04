//
//  BaiduMapViewController.m
//  jqdl
//
//  Created by Stephen Chin on 16/12/16.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "BaiduMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "JZNavigationExtension.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "UIImage+Rotate.h"

#import "WTPoi.h"
#import "MyPointAnnotation.h"
#import "DetailViewController.h"
#import "FeatureTableViewController.h"
#import "MyView.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+SetLabelSpace.h"
#import "Player.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#define WT_RANDOM(startValue, endValue) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (endValue - startValue)) + startValue)

@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end


@interface BaiduMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate,UIScrollViewDelegate>{
    BMKMapView* _mapView;
    BMKLocationService *_locService;
    BMKRouteSearch* _routesearch;
    BOOL locationFlag;
    BOOL locationFlag2;

    CLLocationCoordinate2D start2d;
    CLLocationCoordinate2D end2d;
    
    NSMutableArray *annotations;
    UIScrollView *sv;
    
    UIButton *oldPlayBtn;
    
    
}

@end

@implementation BaiduMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"东湖海洋世界风景区";
    self.navigationItem.titleView = titleLabel;
    
    self.jz_navigationBarBackgroundAlpha = 1.f;
    self.jz_wantsNavigationBarVisible = YES;
    
    //右上角按钮
    UIImage *image = [[UIImage imageNamed:@"listIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(tableStyle)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //添加地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64)];
    [_mapView setZoomLevel:13];
    [self.view addSubview:_mapView];
    
    _routesearch = [[BMKRouteSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    //定位按钮
    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, _mapView.frame.size.height - 108 - 15 - 15 - 44, 44, 44)];
    [locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:locationBtn];
    
    //添加放大缩小按钮
    [self setZoomBtn];

    //添加手绘地图
//    CLLocationCoordinate2D coors;
//    coors.latitude = 30.738861;
//    coors.longitude = 111.327933;
//    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithPosition:coors
//                                                                 zoomLevel:18 anchor:CGPointMake(0.0f,0.0f)
//                                                                      icon:[UIImage imageNamed:@"smap"]];
//    [_mapView addOverlay:ground];
    
    annotations = [NSMutableArray array];
    //添加景点标注
    for (int i = 0; i < _jingdianArray.count; i++) {
        WTPoi *poi = [_jingdianArray objectAtIndex:i];
        //添加PointAnnotation
        MyPointAnnotation* annotation = [[MyPointAnnotation alloc]init];
        CLLocationCoordinate2D coor = poi.location.coordinate;
        annotation.coordinate = coor;
        annotation.title = poi.name;
        annotation.poi = poi;
        annotation.index = i;
        [_mapView addAnnotation:annotation];
        [annotations addObject:annotation];
    }
    
    
    
    //添加底部景点卡片
    MyView *view = [[MyView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height - 15 - 108, Main_Screen_Width, 108)];
    sv = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width - 30, 108)];
    sv.delegate = self;
    sv.clipsToBounds = NO;
    sv.pagingEnabled = YES;
    sv.showsHorizontalScrollIndicator = NO;
    
    CGFloat x = 10;
    for (int i = 0; i < _jingdianArray.count; i++) {
        WTPoi *poi = [_jingdianArray objectAtIndex:i];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, Main_Screen_Width - 40, 108)];
        
        
        v.backgroundColor = [UIColor whiteColor];
        ViewBorderRadius(v, 5, 1, RGBA(0, 0, 0, 0.15));
        //图片
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 108 - 12 * 2, 108 - 12 * 2)];
        imageview.tag = i;
        imageview.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
        [imageview addGestureRecognizer:tap];
        
        imageview.backgroundColor = [UIColor lightGrayColor];
        [imageview setImageWithURL:[NSURL URLWithString:poi.image]];
        ViewBorderRadius(imageview, 2, 0, [UIColor whiteColor]);
        [v addSubview:imageview];
        //文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 12, 12, 0, 0)];
        label.font = BOLDSYSTEMFONT(14);
        label.textColor = RGB(102, 102, 102);
        label.text = [NSString stringWithFormat:@"%d.%@",i+1,poi.name];
        [label sizeToFit];
        [v addSubview:label];
        //描述
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), CGRectGetWidth(v.frame) - label.frame.origin.x - 10, 108 - CGRectGetMaxY(label.frame) - 31)];
        desLabel.font = SYSTEMFONT(12);
        desLabel.textColor = RGB(151, 151, 151);
        desLabel.numberOfLines = 0;
        desLabel.text = @"在海底隧道馆，可以滴水不沾的穿越海洋了!享受海底漫步的乐趣，不仅可…";
//        desLabel.backgroundColor = [UIColor grayColor];
        [UILabel setLabelSpace:desLabel withValue:@"在海底隧道馆，可以滴水不沾的穿越海洋了!享受海底漫步的乐趣，不仅可…" withFont:desLabel.font];
        [v addSubview:desLabel];
        
        
        
//        BMKMapPoint point1 = BMKMapPointForCoordinate(poi.location.coordinate);
//        
//        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(, ));
//        
//        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(v.frame) - 56, CGRectGetHeight(v.frame) - 28, 46, 18)];
        playBtn.tag = i;
        playBtn.titleLabel.font = SYSTEMFONT(10);
        [playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
//        [playBtn setTitle:@"播放" forState:UIControlStateNormal];
//        [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
//        playBtn.backgroundColor = RGB(255, 192, 20);
        [v addSubview:playBtn];
        
        
        [sv addSubview:v];
        x += CGRectGetWidth(v.frame) + 10;
    }
    x-=10;
    [sv setContentSize:CGSizeMake(x, 108)];
    [view addSubview:sv];
    
    [self.view addSubview:view];
    
    if (annotations.count > 0) {
        [_mapView selectAnnotation:annotations[0] animated:YES];
    }
    
    //播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVoiceEnd) name:@"playVoiceEnd" object:nil];
    
    
    
    //    //计算距离
    //    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.915,116.404));
    //    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(38.915,115.404));
    //    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    
    //    //其他坐标系转为百度坐标系
    //    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.90868, 116.3956);//原始坐标
    //    //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
    //    NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    //    //转换GPS坐标至百度坐标(加密后的坐标)
    //    testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
    //    NSLog(@"x=%@,y=%@",[testdic objectForKey:@"x"],[testdic objectForKey:@"y"]);
    //    //解密加密后的坐标字典
    //    CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
    
    //    //1.初始化收藏夹管理类：
    //    BMKFavPoiManager *_favManager = [[BMKFavPoiManager alloc] init];//初始化收藏夹管理类
    //    //2.添加一个收藏点，核心代码如下：
    //    //构造收藏点信息
    //    BMKFavPoiInfo *poiInfo = [[BMKFavPoiInfo alloc] init];
    //    poiInfo.pt = CLLocationCoordinate2DMake(39.908, 116.204);//收藏点坐标
    //    poiInfo.poiName = @"收藏点名称";//收藏点名称
    //    //添加收藏点(收藏点功后会得到favId)
    //    NSInteger res = [_favManager addFavPoi:poiInfo];
    //    //3.获取收藏点，核心代码如下：
    //    //获取所有收藏点
    //    NSArray *allFavPois = [_favManager getAllFavPois];
    //    //获取某个收藏点(收藏点成功后会得到favId)
    //    BMKFavPoiInfo *favPoi = [_favManager getFavPoi:favId];
    //    //4.删除收藏的点，核心代码如下：
    //    //删除所有收藏点
    //    BOOL res = [_favManager clearAllFavPois];
    //    //删除某个收藏点(收藏点成功后会得到favId)
    //    BOOL res = [_favManager deleteFavPoi:favId];
    
}

-(void)setZoomBtn{
    UIView *zoomView = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width - 28 - 15, CGRectGetHeight(_mapView.frame)/2 - 28, 28, 57)];
    zoomView.backgroundColor = [UIColor whiteColor];
    ViewBorderRadius(zoomView, 3, 0, [UIColor whiteColor]);
    
    UIButton *zoomOutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [zoomOutBtn setImage:[UIImage imageNamed:@"zoomOut"] forState:UIControlStateNormal];
    [zoomOutBtn addTarget:self action:@selector(zoomIn) forControlEvents:UIControlEventTouchUpInside];
    [zoomView addSubview:zoomOutBtn];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(6, 28, zoomView.frame.size.width - 12, 0.5)];
    line.backgroundColor = RGBA(80, 80, 80, 0.5);
    [zoomView addSubview:line];
    
    UIButton *zoomInBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 29, 28, 28)];
    [zoomInBtn setImage:[UIImage imageNamed:@"zoomIn"] forState:UIControlStateNormal];
    [zoomInBtn addTarget:self action:@selector(zoomOut) forControlEvents:UIControlEventTouchUpInside];
    [zoomView addSubview:zoomInBtn];
    
    [_mapView addSubview:zoomView];
}

-(void)zoomIn{
    [_mapView zoomIn];
}

-(void)zoomOut{
    [_mapView zoomOut];
}

-(void)playVoice:(UIButton *)btn{
    
    MyPointAnnotation *anno = annotations[btn.tag];
    NSString *voice = anno.poi.voice;
    
    if ([[Player sharedManager] isPlaying]) {//当前正在播放
        NSString *playingUrlStr = [[[Player sharedManager] url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,voice];
        if ([playingUrlStr isEqualToString:path]) {//当前播放的就是该景点的语音 停止播放
            [[Player sharedManager] stop];//先停止播放
//            [btn setTitle:@"播放" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            oldPlayBtn = nil;
        }else{//不是该景点的 重新播放
            [[Player sharedManager] stop];//先停止播放
//            [oldPlayBtn setTitle:@"播放" forState:UIControlStateNormal];
            [oldPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            
            [[Player sharedManager] setUrl:[NSURL URLWithString:path]];
            [[Player sharedManager] play];
//            [btn setTitle:@"暂停" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"playEnd"] forState:UIControlStateNormal];
            oldPlayBtn = btn;
        }
    }else{//当前没有播放
        
        [[Player sharedManager] pause];
        
        NSString *path = [NSString stringWithFormat:@"%@%@",kHost,voice];
        [[Player sharedManager] setUrl:[NSURL URLWithString:path]];
        [[Player sharedManager] play];
//        [btn setTitle:@"暂停" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"playEnd"] forState:UIControlStateNormal];
        oldPlayBtn = btn;
    }
    
}

//播放结束
-(void)playVoiceEnd{
    if (oldPlayBtn) {
//        [oldPlayBtn setTitle:@"播放" forState:UIControlStateNormal];
        [oldPlayBtn setImage:[UIImage imageNamed:@"playEnd"] forState:UIControlStateNormal];
        oldPlayBtn = nil;
    }
}

//景点详情
-(void)toDetail:(UITapGestureRecognizer *)sender{
    DLog(@"%@",sender);
    DetailViewController *vc = [[DetailViewController alloc] init];
    MyPointAnnotation *anno = annotations[sender.view.tag];
    vc.poi = anno.poi;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _routesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    sv.clipsToBounds = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    if (!locationFlag2) {
        locationFlag2 = !locationFlag2;
        [self location];//定位
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playVoiceEnd" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _routesearch.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
    sv.clipsToBounds = YES;
}

#pragma mark - UIScrollViewDelegate

//- (void) scrollViewDidScroll:(UIScrollView *)sender {
//    // 得到每页宽度
//    CGFloat pageWidth = sender.frame.size.width;
//    // 根据当前的x坐标和页宽度计算出当前页数
//    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    DLog(@"%d",currentPage);
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    DLog(@"%d",currentPage);
    
    if (currentPage >= 0 & currentPage < annotations.count) {
        MyPointAnnotation* annotation = [annotations objectAtIndex:currentPage];
        
        
        
        [_mapView selectAnnotation:annotation animated:YES];
        [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
    
    
    
}

#pragma mark - BMKLocationServiceDelegate

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
//    NSLog(@"heading is %@",userLocation.heading);
    [_mapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    [_mapView updateLocationData:userLocation];
    start2d = userLocation.location.coordinate;
    
//    DLog(@"mapView.userLocationVisible:%d",_mapView.userLocationVisible);
    if (!locationFlag) {
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        locationFlag = YES;
    }
    
//    for (int i = 0; i < 10 ; i++) {
//        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude + WT_RANDOM(-0.1, 0.1), userLocation.location.coordinate.longitude + WT_RANDOM(-0.1, 0.1));
//        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//        
//        
//        annotation.coordinate = locationCoordinate;
//        annotation.title = [NSString stringWithFormat:@"%d",i+1];
//        [_mapView addAnnotation:annotation];
//    }
    
}

#pragma mark - BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    DLog(@"regionDidChangeAnimated");
//    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    DLog(@"%f %f",coordinate.latitude,coordinate.longitude);
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MyPointAnnotation class]]) {
        DLog(@"%@",view);
        DLog(@"%@",view.annotation);
        MyPointAnnotation *annotation = (MyPointAnnotation *)view.annotation;
        
        DLog(@"%@",annotation.title);
        
        CLLocationCoordinate2D coors;
        coors.latitude = annotation.coordinate.latitude;
        coors.longitude = annotation.coordinate.longitude;
        end2d = coors;
        
        DLog(@"%f %f",annotation.coordinate.latitude,annotation.coordinate.longitude);
        
        
        [sv setContentOffset:CGPointMake(annotation.index * sv.frame.size.width, 0) animated:NO];
        [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
    
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MyPointAnnotation class]]) {
        MyPointAnnotation *annotation = (MyPointAnnotation *)view.annotation;
        
        DLog(@"%@",annotation.poi.image);
        
        DetailViewController *vc = [[DetailViewController alloc] init];
        vc.poi = annotation.poi;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    if ([overlay isKindOfClass:[BMKGroundOverlay class]]){
        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
        return groundView;
    }
    return nil;
}

// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
    }
    if ([annotation isKindOfClass:[MyPointAnnotation class]]) {
        
        BMKAnnotationView * view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        
        
        //设置标注的图片
        view.image=[UIImage imageNamed:@"greenPoint"];
        //点击显示图详情视图 必须MJPointAnnotation对象设置了标题和副标题
        view.canShowCallout=YES;
        
//        UIButton *daohangBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 32, 32)];
//        daohangBtn.titleLabel.font = SYSTEMFONT(13);
//        [daohangBtn setTitle:@"导航" forState:UIControlStateNormal];
//        [daohangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [daohangBtn addTarget:self action:@selector(onClickWalkSearch) forControlEvents:UIControlEventTouchUpInside];
//        view.rightCalloutAccessoryView=daohangBtn;
        return view;
        
//        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
//        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
//        return newAnnotationView;
    }
    return nil;
}

#pragma mark - BMKRouteSearchDelegate

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RouteAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
    
//    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BMKPolyline class]]) {
            [_mapView removeOverlay:obj];
        }
    }];
    
//    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                NSLog(@"起点\t%f\t%f",plan.starting.location.latitude,plan.starting.location.longitude);
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
                NSLog(@"终点\t%f\t%f",plan.starting.location.latitude,plan.starting.location.longitude);
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            NSLog(@"路段入口\t%f\t%f\t路段入口指示信息:%@",transitStep.entrace.location.latitude,transitStep.entrace.location.longitude,transitStep.entraceInstruction);
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
                
                
                NSLog(@"%d\t轨迹点\t%f\t%f",i,transitStep.points[k].x,transitStep.points[k].y);
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}

#pragma mark -

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

//定位
-(void)location{
    locationFlag = NO;
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [_locService startUserLocationService];
}
//取消定位
-(void)cancelLocation{
    locationFlag = NO;
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
}

-(void)onClickWalkSearch{
    
//    [self cancelLocation];
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
//    start.name = @"天安门";
//    start.cityName = @"北京市";
    start.pt = start2d;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
//    end.name = @"百度大厦";
//    end.cityName = @"北京市";
    end.pt = end2d;
    
    
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [_routesearch walkingSearch:walkingRouteSearchOption];
    if(flag)
    {
        NSLog(@"walk检索发送成功");
    }
    else
    {
        NSLog(@"walk检索发送失败");
    }
}

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

//列表模式
-(void)tableStyle{
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    
    FeatureTableViewController *vc = [FeatureTableViewController new];
    vc.jingdianArray = _jingdianArray;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}

@end
