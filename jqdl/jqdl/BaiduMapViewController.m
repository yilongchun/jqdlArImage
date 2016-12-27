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
#import "JZNavigationExtension.h"

@interface BaiduMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>{
    BMKMapView* _mapView;
    BMKLocationService *_locService;
    BOOL locationFlag;
}

@end

@implementation BaiduMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"东湖海洋世界风景区";
    self.navigationItem.titleView = titleLabel;
    
    self.jz_navigationBarBackgroundAlpha = 1.f;
    self.jz_wantsNavigationBarVisible = YES;
    
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.frame];
    [_mapView setZoomLevel:18];
    self.view = _mapView;
    
    
    _locService = [[BMKLocationService alloc]init];
    
    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, Main_Screen_Height - 44 - 134, 44, 44)];
    [locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:locationBtn];
    
    
    
    
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    CLLocationCoordinate2D coors;
    coors.latitude = 30.738861;
    coors.longitude = 111.327933;
    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithPosition:coors
                                                                 zoomLevel:18 anchor:CGPointMake(0.0f,0.0f)
                                                                      icon:[UIImage imageNamed:@"smap"]];
    [_mapView addOverlay:ground];
    
    
//    // 添加一个PointAnnotation
//    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//    CLLocationCoordinate2D coor;
//    coor.latitude = 39.915;
//    coor.longitude = 116.404;
//    annotation.coordinate = coor;
//    annotation.title = @"这里是北京";
//    [_mapView addAnnotation:annotation];
    
    
    
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self location];//定位
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

#pragma mark - BMKLocationServiceDelegate

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
    [_mapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    [_mapView updateLocationData:userLocation];
    
    DLog(@"mapView.userLocationVisible:%d",_mapView.userLocationVisible);
    if (!locationFlag) {
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        locationFlag = YES;
    }
}

#pragma mark - BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"regionDidChangeAnimated");
}

#pragma mark - BMKMapViewDelegate

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKGroundOverlay class]]){
        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
        return groundView;
    }
    return nil;
}

// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView * view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        //设置标注的图片
        view.image=[UIImage imageNamed:@"greenPoint"];
        //点击显示图详情视图 必须MJPointAnnotation对象设置了标题和副标题
//        view.canShowCallout=YES;
//        //创建了两个view
//        UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//        view1.backgroundColor=[UIColor redColor];
//        UIView * view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
//        view2.backgroundColor=[UIColor blueColor];
//        //设置左右辅助视图
//        view.leftCalloutAccessoryView=view1;
//        view.rightCalloutAccessoryView=view2;
        //设置拖拽 可以通过点击不放进行拖拽
        view.draggable=YES;
        return view;
        
//        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
//        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
//        return newAnnotationView;
    }
    return nil;
}

#pragma mark -

//定位
-(void)location{
    locationFlag = NO;
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    [_locService startUserLocationService];
    
    
}

@end
