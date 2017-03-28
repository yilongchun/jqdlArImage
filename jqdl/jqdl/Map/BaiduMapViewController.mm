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

//#import "WTPoi.h"
#import "MyPointAnnotation.h"
#import "DetailViewController.h"
#import "FeatureListViewController.h"
#import "MyView.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+SetLabelSpace.h"
#import "Player.h"
//#import "CalloutMapAnnotation.h"
//#import "CallOutAnnotationView.h"
#import "UIImage+Color.h"
#import "MyMapImgBtn.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

#define WT_RANDOM(startValue, endValue) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (endValue - startValue)) + startValue)
//弹出视图左侧间隔
#define LEFT_MASK_WIDTH 120

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


@interface BaiduMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKRouteSearchDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    BMKMapView* _mapView;
    BMKLocationService *_locService;
    BMKRouteSearch* _routesearch;
    BOOL locationFlag;
//    BOOL locationFlag2;

    CLLocationCoordinate2D start2d;
    CLLocationCoordinate2D end2d;
    
    NSMutableArray *annotations;
    UIScrollView *sv;
    UIScrollView *typeScrollView;
    UIButton *oldBtn;
    UIButton *oldPlayBtn;
    
    NSURLSessionDownloadTask *_downloadTask;
    
//    CalloutMapAnnotation *_calloutMapAnnotation;
    
    UIView *spotMaskView;//热点遮罩层
    UIView *spotRightView;//热点右侧界面
    UITableView *spotTableView;//列表
    
    UIView *drawMaskView;//手绘地图遮罩层
    UIView *drawRightView;//手绘地图右侧界面
    
    
    NSMutableArray *tuijianArray;//列表推荐
    NSMutableArray *otherArray;//列表其他
    
    UIView *imageMaskView;//图片遮罩层
    UIScrollView *imageScrollView;//图片滚动条
    UILabel *imagePageLabel;//图片滚动页码
    
    
    BMKGroundOverlay* ground;
}

@end

@implementation BaiduMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self checkNetState];
//    [self downloadFile];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = _name;
    self.navigationItem.titleView = titleLabel;
    
    self.jz_navigationBarBackgroundAlpha = 1.f;
    self.jz_wantsNavigationBarVisible = YES;
    
    //右上角按钮
//    UIImage *image = [[UIImage imageNamed:@"listIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(tableStyle)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    
    
    //添加地图
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, Main_Screen_Width, Main_Screen_Height - 64)];
    [_mapView setZoomLevel:13];
    [self.view addSubview:_mapView];
    
    //列表
    UIButton *listBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 12 - 30, 12 + 64, 30, 30)];
    [listBtn setImage:[UIImage imageNamed:@"listIcon2"] forState:UIControlStateNormal];
    [listBtn addTarget:self action:@selector(showFeatureListView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:listBtn];
    
    //手绘地图设置
    UIButton *showShouhuiBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width - 12 - 30, CGRectGetMaxY(listBtn.frame) + 12, 30, 30)];
    [showShouhuiBtn setImage:[UIImage imageNamed:@"showShouhui"] forState:UIControlStateNormal];
    [showShouhuiBtn addTarget:self action:@selector(showDrawMapView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showShouhuiBtn];
    
    
    
    _routesearch = [[BMKRouteSearch alloc]init];
    _locService = [[BMKLocationService alloc]init];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    locationFlag = YES;
    [_locService startUserLocationService];
    
    //定位按钮
    UIButton *locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, _mapView.frame.size.height - 108 - 15 - 15 - 44, 44, 44)];
    [locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:locationBtn];
    
    //添加放大缩小按钮
    [self setZoomBtn];

    //添加手绘地图
//    BMKCoordinateBounds bounds;
     // 左边的上大 下小   右边的左小 右大
//    bounds.northEast = CLLocationCoordinate2DMake(30.772352, 111.275587);
//    bounds.southWest = CLLocationCoordinate2DMake(30.770019, 111.270812);
//    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithBounds:bounds icon:[UIImage imageNamed:@"map"]];
    
    
    //map 三游洞 30.771156, 111.270301
//    CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.771156, 111.270301);
//    ground = [BMKGroundOverlay groundOverlayWithPosition:coors
//                                                                 zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
//                                                                      icon:[UIImage imageNamed:@"map"]];
//    //hyz 汉阳造                                               小 - 下       小 - 左
////    CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.562840, 114.273150);
////    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithPosition:coors
////                                                                 zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
////                                                                      icon:[UIImage imageNamed:@"hyz"]];
////    ground.alpha = 0.5;//透明度
//    [_mapView addOverlay:ground];
    [_mapView setZoomLevel:20.9];
    
    
    
    

    //添加景点分类选择
    CGFloat typeWidth = 76;
    CGFloat typeHeight = 38;
    CGFloat typeSpace = 12;
    typeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locationBtn.frame), CGRectGetMinY(locationBtn.frame)+64+3, Main_Screen_Width - CGRectGetMaxX(locationBtn.frame) - typeSpace, typeHeight)];
//    typeScrollView.backgroundColor = [UIColor grayColor];
    typeScrollView.showsHorizontalScrollIndicator = NO;
    [typeScrollView setContentSize:CGSizeMake(8 * (typeWidth + typeSpace), typeHeight)];
    typeScrollView.tag = 2;
    
    CGFloat typeX = 12;
    for (int i = 0 ; i < 8; i++) {
        UIButton *type1Btn = [[UIButton alloc] initWithFrame:CGRectMake(typeX, 0, typeWidth, typeHeight)];
        
        NSString *name = [NSString stringWithFormat:@"type%d",i+1];
        NSString *nameH = [NSString stringWithFormat:@"type%dH",i+1];
        type1Btn.tag = i;
        [type1Btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        [type1Btn setImage:[UIImage imageNamed:nameH] forState:UIControlStateSelected];
//        [type1Btn setImage:[UIImage imageNamed:@"type1H"] forState:UIControlStateHighlighted];
        [type1Btn addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
        [typeScrollView addSubview:type1Btn];
        typeX += typeWidth + typeSpace;
        if (i == 0) {
            type1Btn.selected = YES;
            oldBtn = type1Btn;
        }
    }
    [self.view addSubview:typeScrollView];
    
    
    
    
    
    //添加景点标注
    annotations = [NSMutableArray array];
    tuijianArray = [NSMutableArray array];
    otherArray = [NSMutableArray array];
   
    for (int i = 0; i < _jingdianArray.count; i++) {
        NSDictionary *poi = [_jingdianArray objectAtIndex:i];
        
        
        //数据筛选分类
        if([[poi objectForKey:@"type"] isEqualToString:@"scenery_spot"]){//景点
            [tuijianArray addObject:poi];
        }else{
            [otherArray addObject:poi];
        }
        
        
        //添加PointAnnotation
        MyPointAnnotation* annotation = [[MyPointAnnotation alloc]init];
        
        
        
//        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(poi.location.coordinate.latitude + 0.00347516, poi.location.coordinate.longitude + 0.01223381);
        CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([[poi objectForKey:@"latitude"] floatValue], [[poi objectForKey:@"longitude"] floatValue]);
        
        NSDictionary* testdic = BMKConvertBaiduCoorFrom(coo,BMK_COORDTYPE_GPS);
        CLLocationCoordinate2D coor = BMKCoorDictionaryDecode(testdic);
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:[NSNumber numberWithFloat:poi.location.coordinate.latitude] forKey:@"latitude"];
//        [dic setObject:[NSNumber numberWithFloat:poi.location.coordinate.longitude] forKey:@"longitude"];
//        [dic setObject:[NSNumber numberWithFloat:poi.location.altitude] forKey:@"altitude"];
//        [dic setObject:poi.name forKey:@"name"];
//        [dic setObject:poi.detailedDescription forKey:@"description"];
//        [dic setObject:poi.image forKey:@"image"];
//        [dic setObject:poi.images forKey:@"images"];
//        [dic setObject:poi.voice forKey:@"voice"];
//        [dic setObject:poi.address forKey:@"address"];
//        [dic setObject:poi.type forKey:@"type"];
        annotation.coordinate = coor;
        annotation.title = [poi objectForKey:@"name"];
        annotation.poi = poi;
        annotation.index = i;
        annotation.pointCalloutInfo = poi;
        [_mapView addAnnotation:annotation];
        [annotations addObject:annotation];
    }
    
    //添加底部景点卡片
    MyView *view = [[MyView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height - 15 - 108, Main_Screen_Width, 108)];
    sv = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, Main_Screen_Width - 30, 108)];
    sv.tag = 1;
    sv.delegate = self;
    sv.clipsToBounds = NO;
    sv.pagingEnabled = YES;
    sv.showsHorizontalScrollIndicator = NO;
    
    CGFloat x = 10;
    for (int i = 0; i < _jingdianArray.count; i++) {
        NSDictionary *poi = [_jingdianArray objectAtIndex:i];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, Main_Screen_Width - 40, 108)];
        
        
        v.backgroundColor = [UIColor whiteColor];
        ViewBorderRadius(v, 5, 1, RGBA(0, 0, 0, 0.15));
        //图片
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 108 - 12 * 2, 108 - 12 * 2)];
        imageview.tag = i;
        
        NSString *description = [poi objectForKey:@"description"];
        if (![description isEqualToString:@""]) {
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
            [imageview addGestureRecognizer:tap];
        }
        
        [imageview setImageWithURL:[NSURL URLWithString:[poi objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"flat"]];
        
        ViewBorderRadius(imageview, 2, 0, [UIColor whiteColor]);
        [v addSubview:imageview];
        //文字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 12, 12, 0, 0)];
        label.font = BOLDSYSTEMFONT(14);
        label.textColor = RGB(102, 102, 102);
        label.text = [NSString stringWithFormat:@"%d.%@",i+1,[poi objectForKey:@"name"]];
        [label sizeToFit];
        [v addSubview:label];
        //描述
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), CGRectGetWidth(v.frame) - label.frame.origin.x - 10, 108 - CGRectGetMaxY(label.frame) - 31)];
        desLabel.font = SYSTEMFONT(12);
        desLabel.textColor = RGB(151, 151, 151);
        desLabel.numberOfLines = 0;
        desLabel.text = [poi objectForKey:@"description"];
//        desLabel.backgroundColor = [UIColor grayColor];
        [UILabel setLabelSpace:desLabel withValue:[poi objectForKey:@"description"] withFont:desLabel.font];
        [v addSubview:desLabel];
        
        
        
//        BMKMapPoint point1 = BMKMapPointForCoordinate(poi.location.coordinate);
//        
//        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(, ));
//        
//        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        NSString *voice = [poi objectForKey:@"voice"];
        if (![voice isEqualToString:@""]) {
            UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(v.frame) - 56, CGRectGetHeight(v.frame) - 28, 46, 18)];
            playBtn.tag = i;
            playBtn.titleLabel.font = SYSTEMFONT(10);
            [playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
            //        [playBtn setTitle:@"播放" forState:UIControlStateNormal];
            //        [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            
            //        playBtn.backgroundColor = RGB(255, 192, 20);
            [v addSubview:playBtn];
        }
        
        
        
        
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
    
    
    [self mapViewFit];
    
    //    //计算距离
    //    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.915,116.404));
    //    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(38.915,115.404));
    //    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    
        //其他坐标系转为百度坐标系
//        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(30.76888888888889, 111.26);//原始坐标
//        //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
//        NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
//        //转换GPS坐标至百度坐标(加密后的坐标)
//        testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
//        NSLog(@"x=%@,y=%@",[testdic objectForKey:@"x"],[testdic objectForKey:@"y"]);
//        //解密加密后的坐标字典
//        CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
//        NSLog(@"转换后:x=%f,y=%f",baiduCoor.latitude,baiduCoor.longitude);
    
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
    
    
//    [_mapView setCenterCoordinate:coors];
    
    if ([self.jingquType isEqualToString:@"1"]) {
        //三游洞 //小 - 下       小 - 左
        CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.771626, 111.270551);
        ground = [BMKGroundOverlay groundOverlayWithPosition:coors
                                                   zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
                                                        icon:[UIImage imageNamed:@"map"]];
        
        //    //hyz 汉阳造                                               小 - 下       小 - 左
        //    //30.563350, 114.273250 30.562840, 114.273150
        //    CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.563350, 114.273250);
        //    ground = [BMKGroundOverlay groundOverlayWithPosition:coors zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
        //                                                                      icon:[UIImage imageNamed:@"hyz"]];
        
        
        //    ground.alpha = 0.5;
        [_mapView addOverlay:ground];
    }
    

}


-(void)mapViewFit{
    
    
    if (annotations.count < 1) {
        return;
    }
    
    MyPointAnnotation* annotation = annotations[0];
    
    BMKMapPoint pt = BMKMapPointForCoordinate(annotation.coordinate);
    
    
    
    double ltX = pt.x;
    double rbX = pt.x;
    double ltY = pt.y;
    double rbY = pt.y;
    
    for (int i = 0 ; i < annotations.count; i++) {
        MyPointAnnotation* annotation = annotations[i];
        BMKMapPoint p = BMKMapPointForCoordinate(annotation.coordinate);
        
        if (p.x < ltX) {
            ltX = p.x;
        }
        if (p.x > rbX) {
            rbX = p.x;
        }
        if (p.y > ltY) {
            ltY = p.y;
        }
        if (p.y < rbY) {
            rbY = p.y;
        }
    }
    BMKMapRect rect = BMKMapRectMake(ltX, ltY, rbX - ltX, rbY - ltY);
    _mapView.visibleMapRect = rect;
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}


//景点分类按钮点击
-(void)typeClick:(UIButton *)btn{
    
    oldBtn.selected = NO;
    if (!btn.selected) {
        btn.selected = YES;
        oldBtn = btn;
    }
    
    
    
    
//    [sv scrollRectToVisible:btn.frame animated:YES];
    
    
    
    
    [_mapView removeAnnotations:annotations];
    
    annotations = [NSMutableArray array];
    [tuijianArray removeAllObjects];
    [otherArray removeAllObjects];
    int index = 0;
    //添加景点标注
    for (int i = 0; i < _jingdianArray.count; i++) {
        NSDictionary *poi = [_jingdianArray objectAtIndex:i];
        NSString *type = [poi objectForKey:@"type"];
        
        if (btn.selected) {
            
            if (btn.tag == 0) {//全部
                
            }else if (btn.tag == 1){//景点
                if(![type isEqualToString:@"scenery_spot"]){
                    continue;
                }
            }else if (btn.tag == 2){//游乐
                if(![type isEqualToString:@"recreational_facility"]){
                    continue;
                }
            }else if (btn.tag == 3){//美食
                if(![type isEqualToString:@"food"]){
                    continue;
                }
            }else if (btn.tag == 4){//商铺
                if(![type isEqualToString:@"shop"]){
                    continue;
                }
            }else if (btn.tag == 5){//公厕
                if(![type isEqualToString:@"toilet"]){
                    continue;
                }
            }else if (btn.tag == 6){//出入口
                if(![type isEqualToString:@"entrance"]){
                    continue;
                }
            }else if (btn.tag == 7){//服务点
                if(![type isEqualToString:@"service_point"]){
                    continue;
                }
            }
            
            //添加PointAnnotation
            MyPointAnnotation* annotation = [[MyPointAnnotation alloc]init];
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[poi objectForKey:@"latitude"] floatValue], [[poi objectForKey:@"longitude"] floatValue]);
            DLog(@"GPS > 百度坐标 转换前 %f %f",coor.longitude,coor.latitude);
            NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
            CLLocationCoordinate2D locationCoordinate = BMKCoorDictionaryDecode(testdic);
            DLog(@"GPS > 百度坐标 转换后 %f %f",locationCoordinate.longitude,locationCoordinate.latitude);
            
            
//            CLLocationCoordinate2D coor = poi.location.coordinate;
            annotation.coordinate = locationCoordinate;
            annotation.title = [poi objectForKey:@"name"];
            annotation.poi = poi;
            annotation.index = index;
            [_mapView addAnnotation:annotation];
            [annotations addObject:annotation];
            
            
            //数据筛选分类
            if([[poi objectForKey:@"type"] isEqualToString:@"scenery_spot"]){//景点
                [tuijianArray addObject:poi];
            }else{
                [otherArray addObject:poi];
            }
            
            
            index++;
        }
    }
    
    if (spotTableView) {
        [spotTableView reloadData];
    }
    
    
    
    
    //添加底部景点卡片
    
    [sv.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    CGFloat x = 10;
    int seq = 0;
    for (int i = 0; i < _jingdianArray.count; i++) {
        NSDictionary *poi = [_jingdianArray objectAtIndex:i];
        NSString *type = [poi objectForKey:@"type"];
        
        if (btn.selected) {
            
            
            if (btn.tag == 0) {//全部
                
            }else if (btn.tag == 1){//景点
                if(![type isEqualToString:@"scenery_spot"]){
                    continue;
                }
            }else if (btn.tag == 2){//游乐
                if(![type isEqualToString:@"recreational_facility"]){
                    continue;
                }
            }else if (btn.tag == 3){//美食
                if(![type isEqualToString:@"food"]){
                    continue;
                }
            }else if (btn.tag == 4){//商铺
                if(![type isEqualToString:@"shop"]){
                    continue;
                }
            }else if (btn.tag == 5){//公厕
                if(![type isEqualToString:@"toilet"]){
                    continue;
                }
            }else if (btn.tag == 6){//出入口
                if(![type isEqualToString:@"entrance"]){
                    continue;
                }
            }else if (btn.tag == 7){//服务点
                if(![type isEqualToString:@"service_point"]){
                    continue;
                }
            }
            
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, Main_Screen_Width - 40, 108)];
            
            
            v.backgroundColor = [UIColor whiteColor];
            ViewBorderRadius(v, 5, 1, RGBA(0, 0, 0, 0.15));
            //图片
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 108 - 12 * 2, 108 - 12 * 2)];
            imageview.tag = seq;
            
            NSString *description = [poi objectForKey:@"description"];
            if (![description isEqualToString:@""]) {
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDetail:)];
                [imageview addGestureRecognizer:tap];
            }
            
            
            
            //        imageview.backgroundColor = [UIColor lightGrayColor];
            
            [imageview setImageWithURL:[NSURL URLWithString:[poi objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"flat"]];
            
            ViewBorderRadius(imageview, 2, 0, [UIColor whiteColor]);
            [v addSubview:imageview];
            //文字
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 12, 12, 0, 0)];
            label.font = BOLDSYSTEMFONT(14);
            label.textColor = RGB(102, 102, 102);
            label.text = [NSString stringWithFormat:@"%d.%@",seq+1,[poi objectForKey:@"name"]];
            [label sizeToFit];
            [v addSubview:label];
            //描述
            UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), CGRectGetWidth(v.frame) - label.frame.origin.x - 10, 108 - CGRectGetMaxY(label.frame) - 31)];
            desLabel.font = SYSTEMFONT(12);
            desLabel.textColor = RGB(151, 151, 151);
            desLabel.numberOfLines = 0;
            desLabel.text = [poi objectForKey:@"description"];
            //        desLabel.backgroundColor = [UIColor grayColor];
            [UILabel setLabelSpace:desLabel withValue:[poi objectForKey:@"description"] withFont:desLabel.font];
            [v addSubview:desLabel];
            
            
            
            //        BMKMapPoint point1 = BMKMapPointForCoordinate(poi.location.coordinate);
            //
            //        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(, ));
            //
            //        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            
            NSString *voice = [poi objectForKey:@"voice"];
            if (![voice isEqualToString:@""]) {
                UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(v.frame) - 56, CGRectGetHeight(v.frame) - 28, 46, 18)];
                playBtn.tag = seq;
                playBtn.titleLabel.font = SYSTEMFONT(10);
                [playBtn addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
                //        [playBtn setTitle:@"播放" forState:UIControlStateNormal];
                //        [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                
                //        playBtn.backgroundColor = RGB(255, 192, 20);
                [v addSubview:playBtn];
            }
            
            
            
            
            [sv addSubview:v];
            x += CGRectGetWidth(v.frame) + 10;
            seq++;
        }
        
        
    }
    x-=10;
    [sv setContentSize:CGSizeMake(x, 108)];
    if (annotations.count > 0) {
        [_mapView selectAnnotation:annotations[0] animated:YES];
    }
   
//    [typeScrollView scrollRectToVisible:btn.frame animated:YES];
    
    if (btn.frame.origin.x >= 100) {
        [typeScrollView setContentOffset:CGPointMake(btn.frame.origin.x - 100, 0) animated:YES];
    }
    
    
    
    
    
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
    line.backgroundColor = RGBA(80, 80, 80, 0.3);
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
    NSString *voice = [anno.poi objectForKey:@"voice"];
    
    if ([[Player sharedManager] isPlaying]) {//当前正在播放
        NSString *playingUrlStr = [[[Player sharedManager] url] absoluteString];
        NSString *path = [NSString stringWithFormat:@"%@%@",@"",voice];
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
        
        [[Player sharedManager] stop];
        
        NSString *path = [NSString stringWithFormat:@"%@%@",@"",voice];
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
        [oldPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
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
              
- (id) processDictionaryIsNSNull:(id)obj{
  const NSString *blank = @"";
  
  if ([obj isKindOfClass:[NSDictionary class]]) {
      NSMutableDictionary *dt = [(NSMutableDictionary*)obj mutableCopy];
      for(NSString *key in [dt allKeys]) {
          id object = [dt objectForKey:key];
          if([object isKindOfClass:[NSNull class]]) {
              [dt setObject:blank
                     forKey:key];
          }
          else if ([object isKindOfClass:[NSString class]]){
              NSString *strobj = (NSString*)object;
              if ([strobj isEqualToString:@"<null>"]) {
                  [dt setObject:blank
                         forKey:key];
              }
          }
//          else if ([object isKindOfClass:[NSArray class]]){
//              NSArray *da = (NSArray*)object;
//              da = [self processDictionaryIsNSNull:da];
//              [dt setObject:da
//                     forKey:key];
//          }
          else if ([object isKindOfClass:[NSDictionary class]]){
              NSDictionary *ddc = (NSDictionary*)object;
              ddc = [self processDictionaryIsNSNull:object];
              [dt setObject:ddc forKey:key];
          }
      }
      return [dt copy];
  }
  else if ([obj isKindOfClass:[NSArray class]]){  
      NSMutableArray *da = [(NSMutableArray*)obj mutableCopy];  
      for (int i=0; i<[da count]; i++) {  
          NSDictionary *dc = [obj objectAtIndex:i];  
          dc = [self processDictionaryIsNSNull:dc];  
          [da replaceObjectAtIndex:i withObject:dc];  
      }  
      return [da copy];  
  }  
  else{  
      return obj;  
  }  
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
//    if (!locationFlag2) {
//        locationFlag2 = !locationFlag2;
//        [self location];//定位
//    }
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

-(void)checkNetState{
    //网络监控句柄
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //status:
        //AFNetworkReachabilityStatusUnknown          = -1,  未知
        //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
        //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
        //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
        
        if (status == AFNetworkReachabilityStatusUnknown) {
            NSLog(@"当前网络未知");
        }else if (status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"当前网络未连接");
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            NSLog(@"当前网络3G");
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            NSLog(@"当前网络WiFi");
        }
    }];
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 1) {//线路
//        [self onClickWalkSearch];
    }else if (btn.tag == 2){//语音
        
    }else if (btn.tag == 3){//vr
        
    }else if (btn.tag == 4){//图片
        MyMapImgBtn *b = (MyMapImgBtn *)btn;
        [self showDetailImage:b.poi];
    }
}

//快捷查看图片
-(void)showDetailImage:(NSDictionary *)poi{
    DLog(@"showDetailImage:%@",poi);
    //遮罩层
    if (imageMaskView == nil) {
        imageMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        imageMaskView.backgroundColor = RGBA(0, 0, 0, 0.7);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDetailImage)];
        [imageMaskView addGestureRecognizer:tap];
    }
    //图片滚动视图
    CGFloat width = Main_Screen_Width - 50*2;
    CGFloat height = width * 2 / 3;
    if (imageScrollView == nil) {
        
        CGRect rect = CGRectMake(50, (Main_Screen_Height - height) / 2, width, height);
        imageScrollView = [[UIScrollView alloc] initWithFrame:rect];
        imageScrollView.backgroundColor = [UIColor grayColor];
        imageScrollView.tag = 2;
        imageScrollView.delegate = self;
        imageScrollView.pagingEnabled = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.bounces = NO;
        ViewBorderRadius(imageScrollView, 3, 2, [UIColor whiteColor]);
    }
    
    //滚动页码
    imagePageLabel = [[UILabel alloc] init];
//    imagePageLabel.backgroundColor = [UIColor redColor];
    imagePageLabel.textColor = [UIColor whiteColor];
    imagePageLabel.font = SYSTEMFONT(9);
    
    NSString *images = [poi objectForKey:@"images"];
    if (images != nil && ![images isEqualToString:@""]) {
        NSArray *imageArr = [images componentsSeparatedByString:@","];
        for (int i = 0; i < imageArr.count; i++) {
            NSString *imageUrl = [imageArr objectAtIndex:i];
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(i*width, 0, width, height)];
            [imageview setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage new]];
            [imageScrollView addSubview:imageview];
        }
        [imageScrollView setContentSize:CGSizeMake(imageArr.count*width, height)];
        imagePageLabel.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)imageArr.count];
    }
    [imagePageLabel setFrame:CGRectMake(CGRectGetMaxX(imageScrollView.frame) - 27, CGRectGetMaxY(imageScrollView.frame) - 20, 25, 18)];
    
    [self.view addSubview:imageMaskView];
    [self.view addSubview:imageScrollView];
    [self.view addSubview:imagePageLabel];
    
}

-(void)hideDetailImage{
    if (imageMaskView) {
        [imageMaskView removeFromSuperview];
        imageMaskView = nil;
    }
    if (imageScrollView) {
        [imageScrollView removeFromSuperview];
        imageScrollView = nil;
    }
    if (imagePageLabel) {
        [imagePageLabel removeFromSuperview];
        imagePageLabel = nil;
    }
}

//kvo观察者触发的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    NSLog(@"keypath:%@,object:%@,change:%@",keyPath,object,change);
    //获取 进度变化
    float chanagefl = [[object valueForKeyPath:keyPath] floatValue];
//    _progressView.progress = chanagefl; //开始不能体现变化,是因为下载的过程是异步的,不能实时的获取值的变化.所以利用多线程的知识解决问题
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        DLog(@"chanagefl:%f",chanagefl);
//        _progressView.progress = chanagefl;
    }];
}

-(void)downloadFile{
    //远程地址
    NSURL *URL = [NSURL URLWithString:@"http://www.baidu.com/img/bdlogo.png"];
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //下载进度
    NSProgress *downloadProgress = nil;
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    _downloadTask = [manager downloadTaskWithRequest:request progress:&downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        DLog(@"cachesPath:%@",cachesPath);
        NSString *path_sandox = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        DLog(@"path_sandox:%@",path_sandox);
        NSString *path = [path_sandox stringByAppendingPathComponent:response.suggestedFilename];
        DLog(@"path:%@",path);
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        DLog(@"completionHandler");
    }];
    //监控下载进度
    [downloadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_downloadTask resume];//开始下载
//    [_downloadTask suspend];//暂停下载
    
    
//    NSString *savedPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/bdlogo2.png"];
//    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
//    NSMutableURLRequest *request =[serializer requestWithMethod:@"POST" URLString:@"http://www.baidu.com/img/bdlogo.png" parameters:nil error:nil];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
//    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        float p = (float)totalBytesRead / totalBytesExpectedToRead;
//        DLog(@"%f",p);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"下载完成");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"下载失败");
//    }];
//    
//    [operation start];
    
    

    
    
    
}

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
    
    FeatureListViewController *vc = [FeatureListViewController new];
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < _jingdianArray.count; i++) {
        WTPoi *poi = [_jingdianArray objectAtIndex:i];
        if ([poi.type isEqualToString:@"scenery_spot"]) {
            [array addObject:poi];
        }
    }
    
    vc.jingdianArray = array;
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

- (void) handlePan: (UISwipeGestureRecognizer *)rec{
    
    if(rec.direction == UISwipeGestureRecognizerDirectionRight){
        if (rec.view.tag == 1) {
            [self hideFeatureListView];
        }
        if (rec.view.tag == 2) {
            [self hideDrawMapView];
        }
        DLog(@"向右");
       
    }else{
        DLog(@"其他方向");
    }
//    rec.view.center = CGPointMake(rec.view.center.x + point.x, rec.view.center.y + point.y);
//    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
}

//热点列表
-(void)showFeatureListView{
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (spotMaskView == nil) {
        spotMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        spotMaskView.backgroundColor = RGBA(0, 0, 0, 0);
       
        UIView *leftMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEFT_MASK_WIDTH, Main_Screen_Height)];
        leftMaskView.tag = 1;
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFeatureListView)];
        [leftMaskView addGestureRecognizer:tapView];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        leftMaskView.userInteractionEnabled = YES;
        [leftMaskView addGestureRecognizer:swipe];
        
        [spotMaskView addSubview:leftMaskView];
        
        spotRightView = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width - LEFT_MASK_WIDTH, Main_Screen_Height)];
        spotRightView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listIcon3"]];
        [imageview setFrame:CGRectMake(14, 34, imageview.frame.size.width, imageview.frame.size.height)];
        [spotRightView addSubview:imageview];
        
        UILabel *tableTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 6, CGRectGetMinY(imageview.frame) - 4, 0, 0)];
        tableTitleLabel.text = @"热点列表";
        tableTitleLabel.textColor = RGBA(51, 51, 51, 1);
        tableTitleLabel.font = BOLDSYSTEMFONT(15);
        [tableTitleLabel sizeToFit];
        [spotRightView addSubview:tableTitleLabel];
        
        
        spotTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Main_Screen_Width - LEFT_MASK_WIDTH, Main_Screen_Height - 64 - 40) style:UITableViewStylePlain];
        spotTableView.delegate = self;
        spotTableView.dataSource = self;
        spotTableView.backgroundColor = [UIColor whiteColor];
        spotTableView.tableFooterView = [[UIView alloc] init];
        [spotRightView addSubview:spotTableView];
        
        [spotMaskView addSubview:spotRightView];
        
        UIButton *clearTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(spotTableView.frame), CGRectGetWidth(spotTableView.frame), 40)];
        [clearTypeBtn setTitle:@"重置筛选" forState:UIControlStateNormal];
        [clearTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [clearTypeBtn setBackgroundImage:[UIImage imageWithColor:RGB(66, 216, 230) size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
        clearTypeBtn.titleLabel.font = SYSTEMFONT(15);
        clearTypeBtn.tag = 0;
        [clearTypeBtn addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
        [spotRightView addSubview:clearTypeBtn];
    }
    
    
    [self.navigationController.view addSubview:spotMaskView];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = spotRightView.frame;
        rect.origin.x = LEFT_MASK_WIDTH;
        spotRightView.frame = rect;
        spotMaskView.backgroundColor = RGBA(0, 0, 0, 0.7);
    }];
    
}
//隐藏热点列表
-(void)hideFeatureListView{
//    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    if (spotMaskView) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = spotRightView.frame;
            rect.origin.x = Main_Screen_Width;
            spotRightView.frame = rect;
            spotMaskView.backgroundColor = RGBA(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            if (finished) {
                [spotMaskView removeFromSuperview];
                spotMaskView = nil;
                // 开启
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                }
            }
        }];
    }
}

-(void)showGround{
//    DLog(@"%@",_mapView.overlays);
    
//    CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.771156, 111.270301);
//    ground = [BMKGroundOverlay groundOverlayWithPosition:coors
//                                               zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
//                                                    icon:[UIImage imageNamed:@"map"]];
    //hyz 汉阳造                                               小 - 下       小 - 左
    //    CLLocationCoordinate2D coors = CLLocationCoordinate2DMake(30.562840, 114.273150);
    //    BMKGroundOverlay* ground = [BMKGroundOverlay groundOverlayWithPosition:coors
    //                                                                 zoomLevel:20.9 anchor:CGPointMake(0.0f,0.0f)
    //                                                                      icon:[UIImage imageNamed:@"hyz"]];
    //    ground.alpha = 0.5;//透明度
//    [_mapView addOverlay:ground];
    if ([self.jingquType isEqualToString:@"1"]) {
        if (![_mapView.overlays containsObject:ground]) {
            [_mapView addOverlay:ground];
        }
    }
    
    
}

-(void)hideGround{
    if ([_mapView.overlays containsObject:ground]) {
        [_mapView removeOverlay:ground];
    }
}

//弹出手绘地图设置
-(void)showDrawMapView{
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (drawMaskView == nil) {
        drawMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        drawMaskView.backgroundColor = RGBA(0, 0, 0, 0);
        
        UIView *leftMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEFT_MASK_WIDTH, Main_Screen_Height)];
        leftMaskView.tag = 2;
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDrawMapView)];
        [leftMaskView addGestureRecognizer:tapView];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        leftMaskView.userInteractionEnabled = YES;
        [leftMaskView addGestureRecognizer:swipe];
        
        [drawMaskView addSubview:leftMaskView];
        
        drawRightView = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width - LEFT_MASK_WIDTH, Main_Screen_Height)];
        drawRightView.backgroundColor = [UIColor whiteColor];
        
        UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 35, 66, 100)];
        [showBtn setImage:[UIImage imageNamed:@"showDraw"] forState:UIControlStateNormal];
//        [showBtn setImage:[UIImage imageWithColor:RGB(67, 216, 230) size:CGSizeMake(10, 10)] forState:UIControlStateHighlighted];
        [showBtn setTitle:@"手绘地图" forState:UIControlStateNormal];
        showBtn.titleLabel.font = SYSTEMFONT(14);
        [showBtn setTitleColor:RGB(67, 216, 230) forState:UIControlStateHighlighted];
        [showBtn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
        [showBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,-86,-74,-19)];
        [showBtn setImageEdgeInsets:UIEdgeInsetsMake(-34, 0, 0, 0)];
        [showBtn addTarget:self action:@selector(showGround) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *hideBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(drawRightView.frame) - 35 - 66, 35, 66, 100)];
        [hideBtn setImage:[UIImage imageNamed:@"hideDraw"] forState:UIControlStateNormal];
//        [hideBtn setImage:[UIImage imageWithColor:RGB(67, 216, 230) size:CGSizeMake(67, 67)] forState:UIControlStateHighlighted];
        [hideBtn setTitle:@"平面地图" forState:UIControlStateNormal];
        hideBtn.titleLabel.font = SYSTEMFONT(14);
        [hideBtn setTitleColor:RGB(67, 216, 230) forState:UIControlStateHighlighted];
        [hideBtn setTitleColor:RGB(68, 68, 68) forState:UIControlStateNormal];
        [hideBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,-86,-74,-19)];
        [hideBtn setImageEdgeInsets:UIEdgeInsetsMake(-34, 0, 0, 0)];
        [hideBtn addTarget:self action:@selector(hideGround) forControlEvents:UIControlEventTouchUpInside];
        
        [drawRightView addSubview:showBtn];
        [drawRightView addSubview:hideBtn];
        
        
        [drawMaskView addSubview:drawRightView];
        
        
    }
    
    
    [self.navigationController.view addSubview:drawMaskView];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = drawRightView.frame;
        rect.origin.x = LEFT_MASK_WIDTH;
        drawRightView.frame = rect;
        drawMaskView.backgroundColor = RGBA(0, 0, 0, 0.7);
    }];
}
//隐藏手绘地图设置
-(void)hideDrawMapView{
    //    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    if (drawMaskView) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = drawRightView.frame;
            rect.origin.x = Main_Screen_Width;
            drawRightView.frame = rect;
            drawMaskView.backgroundColor = RGBA(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            if (finished) {
                [drawMaskView removeFromSuperview];
                drawMaskView = nil;
                // 开启
                if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
                }
            }
        }];
    }
}


#pragma mark - UITableViewDataSource

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"推荐";
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return tuijianArray.count;
    }
    if (section == 1) {
        return otherArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = SYSTEMFONT(15);
        cell.detailTextLabel.font = SYSTEMFONT(13);
    }
    
    if (indexPath.section == 0) {
        NSDictionary *poi = [tuijianArray objectAtIndex:indexPath.row];
        NSString *type = [poi objectForKey:@"type"];
        if([type isEqualToString:@"scenery_spot"]){//景点
            cell.imageView.image = [UIImage imageNamed:@"greenPoint3"];
        }else if([type isEqualToString:@"recreational_facility"]){//游乐
            cell.imageView.image = [UIImage imageNamed:@"bluePoint3"];
        }
        else if([type isEqualToString:@"food"]){//美食
            cell.imageView.image = [UIImage imageNamed:@"yellowPoint2"];
        }
        else if([type isEqualToString:@"shop"]){//商铺
            cell.imageView.image = [UIImage imageNamed:@"purplePoint3"];
        }
        else if([type isEqualToString:@"toilet"]){//公厕
            cell.imageView.image = [UIImage imageNamed:@"brownPoint2"];
        }
        else if([type isEqualToString:@"entrance"]){//出入口
            cell.imageView.image = [UIImage imageNamed:@"linghtGreenPonit3"];
        }
        else if([type isEqualToString:@"service_point"]){//服务点
            cell.imageView.image = [UIImage imageNamed:@"redPoint2"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"greenPoint3"];
        }
        cell.textLabel.text = [poi objectForKey:@"name"];
        
        
        CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([[poi objectForKey:@"latitude"] floatValue], [[poi objectForKey:@"longitude"] floatValue]);
        NSDictionary* testdic = BMKConvertBaiduCoorFrom(coo,BMK_COORDTYPE_GPS);
        CLLocationCoordinate2D coor = BMKCoorDictionaryDecode(testdic);
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(coor);
        BMKMapPoint point2 = BMKMapPointForCoordinate(start2d);
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        if (distance > 999) {
            NSString *dis = [NSString stringWithFormat:@"%.2fkm",distance/1000];
            cell.detailTextLabel.text = dis;
        }else{
            NSString *dis = [NSString stringWithFormat:@"%.fm",distance];
            cell.detailTextLabel.text = dis;
        }
        
        DLog(@"%f\t%@",distance,[poi objectForKey:@"name"]);
    }else if (indexPath.section == 1){
        NSDictionary *poi = [otherArray objectAtIndex:indexPath.row];
        NSString *type = [poi objectForKey:@"type"];
        if([type isEqualToString:@"scenery_spot"]){//景点
            cell.imageView.image = [UIImage imageNamed:@"greenPoint3"];
        }else if([type isEqualToString:@"recreational_facility"]){//游乐
            cell.imageView.image = [UIImage imageNamed:@"bluePoint3"];
        }
        else if([type isEqualToString:@"food"]){//美食
            cell.imageView.image = [UIImage imageNamed:@"yellowPoint2"];
        }
        else if([type isEqualToString:@"shop"]){//商铺
            cell.imageView.image = [UIImage imageNamed:@"purplePoint3"];
        }
        else if([type isEqualToString:@"toilet"]){//公厕
            cell.imageView.image = [UIImage imageNamed:@"brownPoint2"];
        }
        else if([type isEqualToString:@"entrance"]){//出入口
            cell.imageView.image = [UIImage imageNamed:@"linghtGreenPonit3"];
        }
        else if([type isEqualToString:@"service_point"]){//服务点
            cell.imageView.image = [UIImage imageNamed:@"redPoint2"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"greenPoint3"];
        }
        cell.textLabel.text = [poi objectForKey:@"name"];
        
        CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([[poi objectForKey:@"latitude"] floatValue], [[poi objectForKey:@"longitude"] floatValue]);
        NSDictionary* testdic = BMKConvertBaiduCoorFrom(coo,BMK_COORDTYPE_GPS);
        CLLocationCoordinate2D coor = BMKCoorDictionaryDecode(testdic);
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(coor);
        BMKMapPoint point2 = BMKMapPointForCoordinate(start2d);
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        if (distance > 999) {
            NSString *dis = [NSString stringWithFormat:@"%.2fkm",distance/1000];
            cell.detailTextLabel.text = dis;
        }else{
            NSString *dis = [NSString stringWithFormat:@"%.fm",distance];
            cell.detailTextLabel.text = dis;
        }
        
        DLog(@"%f\t%@",distance,[poi objectForKey:@"name"]);
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *ids;
    if (indexPath.section == 0) {
        NSDictionary *poi = [tuijianArray objectAtIndex:indexPath.row];
        DLog(@"%@\t%@",[poi objectForKey:@"ids"],[poi objectForKey:@"name"]);
        ids = [poi objectForKey:@"ids"];
    }else if (indexPath.section == 1){
        NSDictionary *poi = [otherArray objectAtIndex:indexPath.row];
        DLog(@"%@\t%@",[poi objectForKey:@"ids"],[poi objectForKey:@"name"]);
        ids = [poi objectForKey:@"ids"];
    }
    
    
    for (int i = 0; i < annotations.count; i++) {
        MyPointAnnotation* annotation = annotations[i];
        NSDictionary *dic = annotation.poi;
        NSString *ids2 = [dic objectForKey:@"ids"];
        if ([ids2 isEqualToString:ids]) {
            [self hideFeatureListView];
            
            [sv setContentOffset:CGPointMake(i * sv.frame.size.width, 0) animated:NO];
            
            CLLocationCoordinate2D coo = CLLocationCoordinate2DMake([[dic objectForKey:@"latitude"] floatValue], [[dic objectForKey:@"longitude"] floatValue]);
            NSDictionary* testdic = BMKConvertBaiduCoorFrom(coo,BMK_COORDTYPE_GPS);
            CLLocationCoordinate2D coor = BMKCoorDictionaryDecode(testdic);
            [_mapView setCenterCoordinate:coor animated:YES];
            
            [_mapView selectAnnotation:annotations[i] animated:YES];
            break;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width - 100, 24)];
    view.backgroundColor = RGB(242, 242, 242);
    
    if (section == 0) {
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        [imageview setFrame:CGRectMake(15, 7, imageview.frame.size.width, imageview.frame.size.height)];
        [view addSubview:imageview];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageview.frame) + 6, 0, 100, 24)];
        label.text = @"推荐";
        label.textColor = RGB(135, 135, 135);
        label.font = SYSTEMFONT(12);
        [view addSubview:label];
    }
    if (section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 24)];
        label.text = @"其他";
        label.textColor = RGB(135, 135, 135);
        label.font = SYSTEMFONT(12);
        [view addSubview:label];
    }
    
    
    return view;
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
    if (sender.tag == 1) {
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
    }else if (sender.tag == 2){
        // 得到每页宽度
        CGFloat pageWidth = sender.frame.size.width;
        // 根据当前的x坐标和页宽度计算出当前页数
        int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        DLog(@"%d",currentPage);
        
        NSString *text = imagePageLabel.text;
        NSRange range = [text rangeOfString:@"/"];
        
        NSString *s2 = [text substringFromIndex:range.location];
        
        imagePageLabel.text = [NSString stringWithFormat:@"%d%@",currentPage + 1,s2];
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
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
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
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    //起点 终点 节点
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RouteAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
    
    //    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    //线路
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BMKPolyline class]]) {
            [_mapView removeOverlay:obj];
        }
    }];
}

-(void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
//    if (_calloutMapAnnotation&&![view isKindOfClass:[CallOutAnnotationView class]]) {
//        if (_calloutMapAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&& _calloutMapAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
//            [mapView removeAnnotation:_calloutMapAnnotation];
//            _calloutMapAnnotation = nil;
//        }
//    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MyPointAnnotation class]]) {
//        DLog(@"%@",view);
//        DLog(@"%@",view.annotation);
        MyPointAnnotation *annotation = (MyPointAnnotation *)view.annotation;
        
        
        
        
//        //如果点到了这个marker点，什么也不做
//        if (_calloutMapAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&& _calloutMapAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
//            return;
//        }
//        //如果当前显示着calloutview，又触发了select方法，删除这个calloutview annotation
//        if (_calloutMapAnnotation) {
//            [mapView removeAnnotation:_calloutMapAnnotation];
//            _calloutMapAnnotation=nil;
//        }
//        //创建搭载自定义calloutview的annotation
//        _calloutMapAnnotation = [[CalloutMapAnnotation alloc] initWithLatitude:view.annotation.coordinate.latitude andLongitude:view.annotation.coordinate.longitude];
//        //把通过marker(ZNBCPointAnnotation)设置的pointCalloutInfo信息赋值给CalloutMapAnnotation
//        _calloutMapAnnotation.locationInfo = annotation.pointCalloutInfo;
//        [mapView addAnnotation:_calloutMapAnnotation];
//        [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
        
        
        
        
        
////        DLog(@"%@",annotation.title);
//        
        
        
        end2d = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
        
        DLog(@"%@\t%f %f\t%f %f",[annotation.poi objectForKey:@"name"],start2d.latitude,start2d.longitude,end2d.latitude,end2d.longitude);
//
////        DLog(@"%f %f",annotation.coordinate.latitude,annotation.coordinate.longitude);
//        
//        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, -60, 100, 50)];
//        v.backgroundColor = [UIColor whiteColor];
//        
//        
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//        
//        [btn setTitle:@"123" forState:UIControlStateNormal];
//         [btn setTitle:@"456" forState:UIControlStateHighlighted];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        
//        [v addSubview:btn];
//        
//        [view.paopaoView addSubview:v];
        
        
        [sv setContentOffset:CGPointMake(annotation.index * sv.frame.size.width, 0) animated:NO];
        [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
    
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
//    if ([view.annotation isKindOfClass:[MyPointAnnotation class]]) {
//        MyPointAnnotation *annotation = (MyPointAnnotation *)view.annotation;
//        
////        DLog(@"%@",annotation.poi.image);
//        
//        NSString *description = annotation.poi.detailedDescription;
//        if (![description isEqualToString:@""]) {
//            DetailViewController *vc = [[DetailViewController alloc] init];
//            vc.poi = annotation.poi;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        
//    }
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
        MyPointAnnotation *anno = (MyPointAnnotation *)annotation;
        NSDictionary *poi = anno.poi;
        NSString *type = [poi objectForKey:@"type"];
        if([type isEqualToString:@"scenery_spot"]){//景点
            view.image=[UIImage imageNamed:@"greenPoint2"];
        }else if([type isEqualToString:@"recreational_facility"]){//游乐
            view.image=[UIImage imageNamed:@"bluePoint2"];
        }
        else if([type isEqualToString:@"food"]){//美食
            view.image=[UIImage imageNamed:@"yellowPoint2"];
        }
        else if([type isEqualToString:@"shop"]){//商铺
            view.image=[UIImage imageNamed:@"purplePoint2"];
        }
        else if([type isEqualToString:@"toilet"]){//公厕
            view.image=[UIImage imageNamed:@"brownPoint2"];
        }
        else if([type isEqualToString:@"entrance"]){//出入口
            view.image=[UIImage imageNamed:@"linghtGreenPonit2"];
        }
        else if([type isEqualToString:@"service_point"]){//服务点
            view.image=[UIImage imageNamed:@"redPoint2"];
        }
        else {
            view.image=[UIImage imageNamed:@"greenPoint2"];
        }
        //点击显示图详情视图 必须MJPointAnnotation对象设置了标题和副标题
//        view.canShowCallout=NO;
        
        
        CGFloat maxX;
        
        UIView *paopaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 44 + 10)];
        
        UIButton *lineBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        lineBtn.tag = 1;
        [lineBtn setImage:[UIImage imageNamed:@"mapLineBtn"] forState:UIControlStateNormal];
        [lineBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [paopaoBgView addSubview:lineBtn];
        maxX = CGRectGetMaxX(lineBtn.frame);
        
        NSString *voice = [anno.poi objectForKey:@"voice"];
        if (voice != nil && ![voice isEqualToString:@""]) {
            UIButton *voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(maxX + 5, 0, 44, 44)];
            voiceBtn.tag = 2;
            [voiceBtn setImage:[UIImage imageNamed:@"mapVoiceBtn"] forState:UIControlStateNormal];
            [voiceBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [paopaoBgView addSubview:voiceBtn];
            maxX = CGRectGetMaxX(voiceBtn.frame);
        }
        
        UIButton *vrBtn = [[UIButton alloc] initWithFrame:CGRectMake(maxX + 5, 0, 44, 44)];
        vrBtn.tag = 3;
        [vrBtn setImage:[UIImage imageNamed:@"mapVrBtn"] forState:UIControlStateNormal];
        [vrBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [paopaoBgView addSubview:vrBtn];
        maxX = CGRectGetMaxX(vrBtn.frame);
        
        NSString *images = [anno.poi objectForKey:@"images"];
        if (images != nil && ![images isEqualToString:@""]) {
            MyMapImgBtn *imgBtn = [[MyMapImgBtn alloc] initWithFrame:CGRectMake(maxX + 5, 0, 44, 44)];
            imgBtn.tag = 4;
            [imgBtn setImage:[UIImage imageNamed:@"mapImgBtn"] forState:UIControlStateNormal];
            [imgBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            imgBtn.poi = anno.poi;
            [paopaoBgView addSubview:imgBtn];
            maxX = CGRectGetMaxX(imgBtn.frame);
        }
        CGRect frame = paopaoBgView.frame;
        frame.size.width = maxX;
        paopaoBgView.frame = frame;
        BMKActionPaopaoView *paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:paopaoBgView];

        view.paopaoView = paopaoView;
        return view;
        
        
//        CallOutAnnotationView *calloutannotationview = (CallOutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"calloutview"];
//        //否则创建新的calloutView
//        if (!calloutannotationview) {
//            
//            calloutannotationview = [[CallOutAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:@"calloutview"];
//        }
//        
//
////        calloutannotationview.canShowCallout=;
//        calloutannotationview.paopaoView = paopaoView;
//        return calloutannotationview;

    }
    
//    else if ([annotation isKindOfClass:[CalloutMapAnnotation class]]){
//        //此时annotation就是我们calloutview的annotation
//        CalloutMapAnnotation *ann = (CalloutMapAnnotation*)annotation;
//        //如果可以重用
//        CallOutAnnotationView *calloutannotationview = (CallOutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"calloutview"];
//        //否则创建新的calloutView
//        if (!calloutannotationview) {
//            calloutannotationview = [[CallOutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"calloutview"];
////            BusPointCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BusPointCell" owner:self options:nil] objectAtIndex:0];
////            [calloutannotationview.contentView addSubview:cell];
////            calloutannotationview.busInfoView = cell;
//            
//            UIButton *lineBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//            lineBtn.tag = 1;
//            [lineBtn setImage:[UIImage imageNamed:@"mapLineBtn"] forState:UIControlStateNormal];
//            [lineBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIButton *voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineBtn.frame) + 5, 0, 44, 44)];
//            voiceBtn.tag = 2;
//            [voiceBtn setImage:[UIImage imageNamed:@"mapVoiceBtn"] forState:UIControlStateNormal];
//            [voiceBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIButton *vrBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(voiceBtn.frame) + 5, 0, 44, 44)];
//            vrBtn.tag = 3;
//            [vrBtn setImage:[UIImage imageNamed:@"mapVrBtn"] forState:UIControlStateNormal];
//            [vrBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIButton *imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(vrBtn.frame) + 5, 0, 44, 44)];
//            imgBtn.tag = 4;
//            [imgBtn setImage:[UIImage imageNamed:@"mapImgBtn"] forState:UIControlStateNormal];
//            [imgBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [calloutannotationview.contentView addSubview:lineBtn];
//            [calloutannotationview.contentView addSubview:voiceBtn];
//            [calloutannotationview.contentView addSubview:vrBtn];
//            [calloutannotationview.contentView addSubview:imgBtn];
//        }
//        
//        NSDictionary *info = ann.locationInfo;
//        DLog(@"inif:%@",info);
////        //开始设置添加marker时的赋值
////        calloutannotationview.busInfoView.aliasLabel.text = [ann.locationInfo objectForKey:@"alias"];
////        calloutannotationview.busInfoView.speedLabel.text = [ann.locationInfo objectForKey:@"speed"];
////        calloutannotationview.busInfoView.degreeLabel.text =[ann.locationInfo objectForKey:@"degree"];
////        calloutannotationview.busInfoView.nameLabel.text = [ann.locationInfo objectForKey:@"name"];
//        
//        
//        
//        
//        
//        
//        calloutannotationview.canShowCallout=NO;
//        return calloutannotationview;
//    }
    return nil;
}



#pragma mark - BMKRouteSearchDelegate

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    
    
    //起点 终点 节点
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RouteAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
    
//    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    //线路
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



@end
