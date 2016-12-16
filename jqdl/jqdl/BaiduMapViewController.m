//
//  BaiduMapViewController.m
//  jqdl
//
//  Created by Stephen Chin on 16/12/16.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import "BaiduMapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "JZNavigationExtension.h"

@interface BaiduMapViewController ()<BMKMapViewDelegate>{
    BMKMapView* mapView;
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
    
    mapView = [[BMKMapView alloc]initWithFrame:self.view.frame];
    self.view = mapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [mapView viewWillAppear];
    mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mapView viewWillDisappear];
    mapView.delegate = nil; // 不用时，置nil
}

@end
