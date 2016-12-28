//
//  ViewController.m
//  AugmentedRealityApplication
//
//  Created by Wikitude GmbH on 22/04/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "ViewController.h"

#import <WikitudeSDK/WikitudeSDK.h>
/* Wikitude SDK debugging */
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>
#import "NSURL+ParameterQuery.h"

#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

#import "WTPoi.h"
#import "WTPoiManager.h"
#import "DetailViewController.h"
#import <Social/Social.h>

#import "FeatureViewController.h"
#import "ChooseJqViewController.h"
#import "LBXScanViewController.h"
#import "Data.h"
#import "CategoryList.h"
#import "Feature2ViewController.h"

#import "JZNavigationExtension.h"
#import "BaiduMapViewController.h"

#import "MoreFunctionViewController.h"
#import "DetailViewController.h"



/* this is used to create random positions around you */
#define WT_RANDOM(startValue, endValue) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (endValue - startValue)) + startValue)

static char *kWTAugmentedRealityViewController_AssociatedPoiManagerKey = "kWTARVCAMEWTP";
static char *kWTAugmentedRealityViewController_AssociatedLocationManagerKey = "kWTARVCAMECLK";

@interface ViewController () <WTArchitectViewDelegate, WTArchitectViewDebugDelegate, CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSString *firsetParams;
    ChooseJqViewController *jqvc;
    CLLocation *myLocation;
    
    
    UITableView *jingdianTableView;
    NSMutableArray *jingdianArray;
    
    UIView *navigationInfoView;
}

/* Add a strong property to the main Wikitude SDK component, the WTArchitectView */
@property (nonatomic, strong) WTArchitectView               *architectView;

/* And keep a weak property to the navigation object which represents the loading status of your Architect World */
@property (nonatomic, weak) WTNavigation                    *architectWorldNavigation;

@end

@implementation ViewController

- (void)startLocationUpdatesForPoiInjection
{
    WTPoiManager *poiManager = [[WTPoiManager alloc] init];
    objc_setAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedPoiManagerKey, poiManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    objc_setAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedLocationManagerKey, locationManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager locationServicesEnabled]) { // 判断是否打开了位置服务
        [locationManager startUpdatingLocation];
    }

}

#pragma mark - Delegation
#pragma mark CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    id firstLocation = [locations firstObject];
    if ( firstLocation )
    {
        
        
        
        myLocation = (CLLocation *)firstLocation;
        [manager stopUpdatingLocation];
        
        //加载数据
        [self loadJqList];
        
        manager.delegate = nil;
//
//        [self generatePois:1 aroundLocation:location];
//        
//        WTPoiManager *poiManager = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedPoiManagerKey);
//        NSString *poisInJsonData = [poiManager convertPoiModelToJson];
//        
//        [self.architectView callJavaScript:[NSString stringWithFormat:@"World.loadPoisFromJsonData(%@)", poisInJsonData]];
    }
}

/** 不能获取位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"获取定位失败");
}

- (void)generatePois:(NSUInteger)numberOfPois aroundLocation:(CLLocation *)referenceLocation
{
    WTPoiManager *poiManager = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedPoiManagerKey);
    [poiManager removeAllPois];
    
    for (NSUInteger i = 0; i < numberOfPois; ++i) {
        
        NSString *poiName = [NSString stringWithFormat:@"POI #%lu", (unsigned long)i];
        NSString *poiDescription = [NSString stringWithFormat:@"Probably one of the best POIs you have ever seen. This is the description of Poi #%lu", (unsigned long)i];
        
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(referenceLocation.coordinate.latitude + WT_RANDOM(-0.3, 0.3), referenceLocation.coordinate.longitude + WT_RANDOM(-0.3, 0.3));
        CLLocationDistance altitude = referenceLocation.verticalAccuracy > 0 ? referenceLocation.altitude + WT_RANDOM(0, 200) : -32768.f;
        
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:locationCoordinate
                                                             altitude:altitude
                                                   horizontalAccuracy:referenceLocation.horizontalAccuracy
                                                     verticalAccuracy:referenceLocation.verticalAccuracy
                                                            timestamp:referenceLocation.timestamp];
        
        WTPoi *poi = [[WTPoi alloc] initWithIdentifier:[NSString stringWithFormat:@"%lu",(unsigned long)i]
                                              location:location
                                                  name:poiName
                                   detailedDescription:poiDescription
                                                 image:@""];
        
        
        [poiManager addPoi:poi];
    }
    
}

- (void)dealloc
{
    /* Remove this view controller from the default Notification Center so that it can be released properly */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /* It might be the case that the device which is running the application does not fulfill all Wikitude SDK hardware requirements.
     To check for this and handle the situation properly, use the -isDeviceSupportedForRequiredFeatures:error class method.
     
     Required features specify in more detail what your Architect World intends to do. Depending on your intentions, more or less devices might be supported.
     e.g. an iPod Touch is missing some hardware components so that Geo augmented reality does not work, but 2D tracking does.
     
     NOTE: On iOS, an unsupported device might be an iPhone 3GS for image recognition or an iPod Touch 4th generation for Geo augmented reality.
     */
    
    self.jz_navigationBarBackgroundHidden = YES;
    self.jz_navigationBarTintColor = [UIColor whiteColor];
    self.jz_navigationBarBackgroundAlpha = 0.f;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = BOLDSYSTEMFONT(17);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"沿江大道";
    self.navigationItem.titleView = titleLabel;
    
//    self.title = @"东湖海洋世界风景区";
    
    self.navigationController.navigationBar.translucent = YES;
    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"地图" style:UIBarButtonItemStyleDone target:self action:@selector(toMap)];
//    [leftItem setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"msg"] style:UIBarButtonItemStyleDone target:self action:@selector(openMoreFunctionView)];
    [rightItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    
    
    
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    NSError *deviceSupportError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_2DTracking error:&deviceSupportError] ) {
        
        /* Standard WTArchitectView object creation and initial configuration */
        self.architectView = [[WTArchitectView alloc] initWithFrame:CGRectZero motionManager:nil];
        self.architectView.delegate = self;
        self.architectView.debugDelegate = self;
        
        /* Use the -setLicenseKey method to unlock all Wikitude SDK features that you bought with your license. */
        
        [self.architectView setLicenseKey:@"VZXuOlo5BrXcfg1u/SZHDsH8Z0WVK2GgKXNc6oSdGR9xdf8u+4QUfIMmV/xpm5OVskMWk/civMgaG69IeCpx06lDfwJCjJ6aML8lguA++GE4+y40GADJyaogsgLxPy02rNcecAqy0JacWlQFNR0yIspw+S4QYiGShktm+mNo96lTYWx0ZWRfX0u5ZeaGCsrwxQpy2pligySNSBTSMVuiX58BLoqX3WHoFRRT6Eg8cOHHLhBi43rzW8aG9eDaT5qdrJY+hE04NU8HvQR8YC6Y9ljsLdL4qA0PSHTebTs2tn9TR2KyCTw45RKMa4SJi7p7ItFqzXevPzhg+MGh1OuNPk1d30Mkpm2AGzimQEQ9JB7aHFcqwwj8ukC20ZPYcWLO2qG3giSVomEJ3swCJ2VWQAVfkt7JLBIhjQ3eKpu/SgrGcrV/ijAplPgs/tpvacyEyybBIsOMwxc3up4kWK4rr+c1BmG0H5jPXmWMqbHnrZ4S/bUWVovqdxhpn/djZZ8Ki/R370iLhxU5b3V8dtLs6LqQcBG5mbZ0B5hyJ/F6lnAnfAh1ccdOru9ArbbJry1AZ3/nvakLcv5ja5EHEL42jafeg6leNJFOmFLOghZ4N2fY7qusmSCy+8Vq1ZK38ApnghE7Q6wO1QqwNwcMiDOYLg=="];
        
        /* The Architect World can be loaded independently from the WTArchitectView rendering.
         
         NOTE: The architectWorldNavigation property is assigned at this point. The navigation object is valid until another Architect World is loaded.
         */
//        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"ArchitectWorld"] withRequiredFeatures:WTFeature_2DTracking];
        
        [self startLocationUpdatesForPoiInjection];
        
        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"ArchitectWorld"] withRequiredFeatures:WTFeature_Geo];
        
        
        
        /* Because the WTArchitectView does some OpenGL rendering, frame updates have to be suspended and resumed when the application changes its active state.
         Here, UIApplication notifications are used to respond to the active state changes.
         
         NOTE: Since the application will resign active even when an UIAlert is shown, some special handling is implemented in the UIApplicationDidBecomeActiveNotification.
         */
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            /* When the application starts for the first time, several UIAlert's might be shown to ask the user for camera and/or GPS access.
             Because the WTArchitectView is paused when the application resigns active (See line 86), also Architect JavaScript evaluation is interrupted.
             To resume properly from the inactive state, the Architect World has to be reloaded if and only if an active Architect World load request was active at the time the application resigned active.
             This loading state/interruption can be detected using the navigation object that was returned from the -loadArchitectWorldFromURL:withRequiredFeatures method.
             */
            if (self.architectWorldNavigation.wasInterrupted) {
                [self.architectView reloadArchitectWorld];
            }
            
            /* Standard WTArchitectView rendering resuming after the application becomes active again */
            [self startWikitudeSDKRendering];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            /* Standard WTArchitectView rendering suspension when the application resignes active */
            [self stopWikitudeSDKRendering];
        }];
        
        /* Standard subview handling using Autolayout */
        [self.view addSubview:self.architectView];
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
    }
    else {
        NSLog(@"This device is not supported. Show either an alert or use this class method even before presenting the view controller that manages the WTArchitectView. Error: %@", [deviceSupportError localizedDescription]);
    }
    
    
    //选择景区
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseJq:) name:@"chooseJq" object:nil];
    //景点详情
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showJdDetail:) name:@"showJdDetail" object:nil];
    
    
   //右下角搜索按钮
//    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-49, Main_Screen_Height-50-38-10, 49, 50)];
//    [searchBtn setImage:[UIImage imageNamed:@"searchBtn"] forState:UIControlStateNormal];
//    [self.view addSubview:searchBtn];
    
}


//进入景区列表选择
-(void)chooseJq{
    if (jqvc == nil) {
        jqvc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseJqViewController"];
        jqvc.hidesBottomBarWhenPushed = YES;
        
    }
    jqvc.categoryListId = categoryList.id;
    [self.navigationController pushViewController:jqvc animated:YES];
    
}

//选择景区完成
- (void)chooseJq:(NSNotification *)text{
    
    
    
    if ([text.userInfo[@"obj"] isKindOfClass:[CategoryList class]]) {
        categoryList = (CategoryList *)text.userInfo[@"obj"];
        firsetParams = categoryList.urlCode;
        NSNumber *flag = text.userInfo[@"SHOWFLAG"];
        
        
        [self loadJingdian:categoryList.id showHud:[flag boolValue]];
        
    }
}

//加载景点列表
-(void)loadJingdian:(NSString *)ids showHud:(BOOL)flag{
    if (flag) {
        [self showHudInView:self.view hint:@"加载中"];
    }
    
    NSDictionary *parameters = @{@"parentId":ids};
    [[Client defaultNetClient] POST:API_JINGDIAN_LIST param:parameters JSONModelClass:[Data class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"JSONModel: %@", responseObject);
        Data *res = (Data *)responseObject;
        if (res.resultcode == ResultCodeSuccess) {
            
//            if (jingdianDataSource==nil) {
//                jingdianDataSource = [NSMutableArray new];
//            }else{
//                [jingdianDataSource removeAllObjects];
//            }
            
            WTPoiManager *poiManager = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedPoiManagerKey);
            [poiManager removeAllPois];
            
            NSError *error;
            NSArray *arr = (NSArray*)res.result;
            
            
            if (jingdianArray == nil) {
                jingdianArray = [NSMutableArray array];
            }
            jingdianArray = [NSMutableArray arrayWithArray:arr];
            
            NSMutableArray *annotations = [NSMutableArray array];
            for (int i = 0;i<arr.count;i++) {
                NSDictionary *dic = arr[i];
                error = nil;
                CategoryList *jingdianList = [[CategoryList alloc] initWithDictionary:dic error:&error];
                DLog(@"%@\t%@\t%f\t%f",jingdianList.id,jingdianList.name,[jingdianList.lon floatValue],[jingdianList.lat floatValue]);
                if (error) {
                    DLog(@"%@",error.userInfo);
                    continue;
                }
                if ([jingdianList.lat floatValue] != 0 && [jingdianList.lon floatValue] != 0) {
//                    [jingdianDataSource addObject:jingdianList];
                    
//                    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([jingdianList.lat floatValue], [jingdianList.lon floatValue]);
                    
                    
                    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(myLocation.coordinate.latitude + WT_RANDOM(-0.1, 0.1), myLocation.coordinate.longitude + WT_RANDOM(-0.1, 0.1));
                    
                    
                    CLLocation *location = [[CLLocation alloc] initWithCoordinate:locationCoordinate
                                                                         altitude:0
                                                               horizontalAccuracy:0
                                                                 verticalAccuracy:0
                                                                        timestamp:[NSDate date]];
                    
                    WTPoi *poi = [[WTPoi alloc] initWithIdentifier:jingdianList.id
                                                          location:location
                                                              name:jingdianList.name
                                               detailedDescription:jingdianList.urlCode
                                                             image:[NSString stringWithFormat:@"%@%@",kHost,jingdianList.image]];
                    DLog(@"%@",poi.jsonRepresentation);
                    
                    [poiManager addPoi:poi];
                    
                }
            }
            if ([annotations count] != 0) {
                
            }
            
            
            NSString *poisInJsonData = [poiManager convertPoiModelToJson];
            
            [self.architectView callJavaScript:[NSString stringWithFormat:@"World.loadPoisFromJsonData(%@)", poisInJsonData]];
            
            [self hideHud];
        }else {
            DLog(@"%@",res.reason);
            [self hideHud];
            [self showHint:res.reason];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        [self hideHud];
        [self showHint:@"获取失败，请重试!"];
        return;
    }];
}

//跳转景点介绍
- (void)showJdDetail:(NSNotification *)text{
    //    if ([text.userInfo[@"obj"] isKindOfClass:[CustomAnnotationView class]]) {
    //
    //
    //        CustomAnnotationView *anno = (CustomAnnotationView *)text.userInfo[@"obj"];
    ////        FeatureViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeatureViewController"];
    ////        vc.hidesBottomBarWhenPushed = YES;
    ////        vc.categoryList = anno.categoryList;
    //
    //        Feature2ViewController *vc = [[Feature2ViewController alloc] init];
    //        vc.title = anno.categoryList.name;
    //        NSString *secondParams = anno.categoryList.urlCode;
    //        vc.url = [NSString stringWithFormat:@"view-%@-",secondParams];
    //        vc.hidesBottomBarWhenPushed = YES;
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }
}

//加载景区列表 读取第一个默认加载
-(void)loadJqList{
    [self showHudInView:self.view hint:@"加载中"];
    
    NSDictionary *parameters = @{@"type":@"1"};
    [[Client defaultNetClient] POST:API_CATEGORY_LIST param:parameters JSONModelClass:[Data class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        DLog(@"JSONModel: %@", responseObject);
        Data *res = (Data *)responseObject;
        if (res.resultcode == ResultCodeSuccess) {
            
            NSError *error;
            NSArray *arr = (NSArray*)res.result;
            
            if ([arr count] > 0) {
                error = nil;
                categoryList = [[CategoryList alloc] initWithDictionary:[arr objectAtIndex:0] error:&error];
                NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:categoryList,@"obj",[NSNumber numberWithBool:NO],@"SHOWFLAG", nil];
                NSNotification *notification =[NSNotification notificationWithName:@"chooseJq" object:nil userInfo:dict];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }else{
                [self hideHud];
                [self showHint:@"暂无景区数据"];
            }
        }else {
            DLog(@"%@",res.reason);
            [self hideHud];
            [self showHint:res.reason];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Error: %@", error);
        [self hideHud];
        [self showHint:@"获取失败!"];
        return;
    }];
}



#pragma mark - Public Methods

- (void)captureScreen
{
    if ( [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] )
    {
        NSDictionary* info = @{};
        [self.architectView captureScreenWithMode: WTScreenshotCaptureMode_CamAndWebView usingSaveMode:WTScreenshotSaveMode_Delegate saveOptions:WTScreenshotSaveOption_None context:info];
    }
    else
    {
        NSDictionary* info = @{};
        [self.architectView captureScreenWithMode: WTScreenshotCaptureMode_CamAndWebView usingSaveMode:WTScreenshotSaveMode_PhotoLibrary saveOptions:WTScreenshotSaveOption_CallDelegateOnSuccess context:info];
    }
}

-(void)showList{
    
    if (jingdianTableView == nil) {
        jingdianTableView = [[UITableView alloc] initWithFrame:CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-80, Main_Screen_Height - 49 - 64) style:UITableViewStylePlain];
        jingdianTableView.alpha = 0.95;
        jingdianTableView.backgroundColor = [UIColor whiteColor];
        jingdianTableView.delegate = self;
        jingdianTableView.dataSource = self;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [jingdianTableView setTableFooterView:v];
    }
    [self.view addSubview:jingdianTableView];
    [UIView transitionWithView:jingdianTableView duration:0.3 options:0 animations:^{
        jingdianTableView.frame = CGRectMake(80, 0, Main_Screen_Width-80, Main_Screen_Height- 49 -64);
    } completion:^(BOOL finished) {
        
    }];
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width, 64, Main_Screen_Width-80, Main_Screen_Height - 64 - 49)];
//    view.backgroundColor = [UIColor whiteColor];
//    view.alpha = 0.9;
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView:)];
//    [view addGestureRecognizer:tap];
//    
//    [self.view addSubview:view];
//    
//    
//    [UIView transitionWithView:view duration:0.3 options:0 animations:^{
//        view.frame = CGRectMake(80, 64, Main_Screen_Width-80, Main_Screen_Height - 64 - 49);
//    } completion:^(BOOL finished) {
//        
//    }];
    
}
//-(void)hideView:(UIGestureRecognizer *)recogn{
//    [UIView transitionWithView:recogn.view duration:0.3 options:0 animations:^{
//        recogn.view.frame = CGRectMake(Main_Screen_Width, 64, Main_Screen_Width-80, Main_Screen_Height - 64 - 49);
//    } completion:^(BOOL finished) {
//        [recogn.view removeFromSuperview];
//    }];
//}


//显示导航数据
-(void)showNavigationInfoView{
//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height - 49)];
//    [self.view addSubview:backgroundView];
    
    self.architectView.userInteractionEnabled = NO;
    
    if (navigationInfoView == nil) {
        navigationInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, -120, Main_Screen_Width, 120)];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [closeBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(hideNavigationInfoView) forControlEvents:UIControlEventTouchUpInside];
        [navigationInfoView addSubview:closeBtn];
        
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, Main_Screen_Width, 0.5)];
        line.backgroundColor = RGB(229, 229, 229);
        [navigationInfoView addSubview:line];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, Main_Screen_Width - 80, 40)];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.text = @"2 分钟   0.1 公里   09:24 到达";
        label1.font = [UIFont systemFontOfSize:15];
        [navigationInfoView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, Main_Screen_Width, 40)];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.font = [UIFont systemFontOfSize:25];
        label2.text = @"136米";
        [navigationInfoView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, Main_Screen_Width, 40)];
        label3.textAlignment = NSTextAlignmentCenter;
        label3.font = [UIFont systemFontOfSize:17];
        label3.text = @"到达目的地";
        [navigationInfoView addSubview:label3];
        
        navigationInfoView.backgroundColor = [UIColor whiteColor];
    }
    
    
//    navigationView.alpha = 0.95;
    [self.view addSubview:navigationInfoView];
    [UIView transitionWithView:navigationInfoView duration:0.3 options:0 animations:^{
        navigationInfoView.frame = CGRectMake(0, 0, Main_Screen_Width, 120);
    } completion:nil];
}

-(void)hideNavigationInfoView{
    if (navigationInfoView) {
        [UIView transitionWithView:navigationInfoView duration:0.3 options:0 animations:^{
            navigationInfoView.frame = CGRectMake(0, -120, Main_Screen_Width, 120);
        } completion:^(BOOL finished) {
            self.architectView.userInteractionEnabled = YES;
            [navigationInfoView removeFromSuperview];
        }];

    }
}

-(void)toMap{
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back2"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    
    BaiduMapViewController *vc = [BaiduMapViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)openMoreFunctionView{
    MoreFunctionViewController *vc = [MoreFunctionViewController new];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];
}

//扫一扫
-(void)saoyisao{
    
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    style.colorAngle = [UIColor colorWithRed:38./255 green:203./255. blue:216./255. alpha:1.0];
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    style.animationImage = imgLine;
    
    LBXScanViewController *vc = [LBXScanViewController new];
    vc.style = style;
    vc.isQQSimulator = YES;
    vc.title = @"扫描二维码";
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (jingdianArray) {
        return jingdianArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dic = jingdianArray[indexPath.row];
    NSError *error = nil;
    CategoryList *jingdianList = [[CategoryList alloc] initWithDictionary:dic error:&error];
    cell.textLabel.text = jingdianList.name;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [UIView transitionWithView:tableView duration:0.3 options:0 animations:^{
        tableView.frame = CGRectMake(Main_Screen_Width, 0, Main_Screen_Width-80, Main_Screen_Height - 64 - 49);
    } completion:^(BOOL finished) {
        [tableView removeFromSuperview];
    }];
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

#pragma mark - Delegation
#pragma mark WTArchitectView

- (void)architectView:(WTArchitectView *)architectView didCaptureScreenWithContext:(NSDictionary *)context
{
    UIImage* image = (UIImage *)[context objectForKey:kWTScreenshotImageKey];
    WTScreenshotSaveMode saveMode = [[context objectForKey:kWTScreenshotSaveModeKey] unsignedIntegerValue];
    
    switch (saveMode)
    {
        case WTScreenshotSaveMode_Delegate:
        [self postImageOnFacebook:image];
        break;
        
        case WTScreenshotSaveMode_PhotoLibrary:
        [self showPhotoLibraryAlert];
        break;
        
        default:
        break;
    }
    
}

- (void)architectView:(WTArchitectView *)architectView didFailCaptureScreenWithError:(NSError *)error
{
    NSLog(@"Error capturing screen: %@", error);
}

#pragma mark - Private Methods

- (void)postImageOnFacebook:(UIImage *)image
{
    SLComposeViewController* composerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
    [composerSheet setInitialText:@"Wikitude screen shot"];
    [composerSheet addImage:image];
    [composerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result)
        {
            case SLComposeViewControllerResultDone:
            output = @"Post Successfull";
            break;
            
            case SLComposeViewControllerResultCancelled:
            output = @"Action Cancelled";
            break;
            
            default:
            break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Weibo" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    
    [self presentViewController:composerSheet animated:YES completion:nil];
}

- (void)showPhotoLibraryAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"截图已保存到手机相册" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - View Lifecycle
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //修改导航栏标题字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    /* WTArchitectView rendering is started once the view controllers view will appear */
    [self startWikitudeSDKRendering];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    /* WTArchitectView rendering is stopped once the view controllers view did disappear */
    [self stopWikitudeSDKRendering];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

/* Convenience methods to manage WTArchitectView rendering. */
- (void)startWikitudeSDKRendering{
    
    /* To check if the WTArchitectView is currently rendering, the isRunning property can be used */
    if ( ![self.architectView isRunning] ) {
        
        /* To start WTArchitectView rendering and control the startup phase, the -start:completion method can be used */
        [self.architectView start:^(WTStartupConfiguration *configuration) {
            
            /* Use the configuration object to take control about the WTArchitectView startup phase */
            /* You can e.g. start with an active front camera instead of the default back camera */
            
            // configuration.captureDevicePosition = AVCaptureDevicePositionFront;
            
        } completion:^(BOOL isRunning, NSError *error) {
            
            /* The completion block is called right after the internal start method returns.
             
             NOTE: In case some requirements are not given, the WTArchitectView might not be started and returns NO for isRunning.
             To determine what caused the problem, the localized error description can be used.
             */
            if ( !isRunning ) {
                NSLog(@"WTArchitectView could not be started. Reason: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)stopWikitudeSDKRendering {
    
    /* The stop method is blocking until the rendering and camera access is stopped */
    if ( [self.architectView isRunning] ) {
        [self.architectView stop];
    }
}

/* The WTArchitectView provides two delegates to interact with. */
#pragma mark - Delegation

/* The standard delegate can be used to get information about:
 * The Architect World loading progress
 * architectsdk:// protocol invocations using document.location inside JavaScript
 * Managing view capturing
 * Customizing view controller presentation that is triggered from the WTArchitectView
 */
#pragma mark WTArchitectViewDelegate
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"Architect World from URL '%@' could not be loaded. Reason: %@", navigation.originalURL, [error localizedDescription]);
}

- (void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL
{
    NSDictionary *parameters = [URL URLParameter];
    if ( parameters )
    {
        if ( [[URL absoluteString] hasPrefix:@"architectsdk://button"] )
        {
            NSString *action = [parameters objectForKey:@"action"];
            if ( [action isEqualToString:@"captureScreen"] )
            {
                [self captureScreen];
            }
            if ([action isEqualToString:@"showList"]) {
//                [self showList];
                [self toMap];
            }
            if ([action isEqualToString:@"showNavigationInfo"]) {
                [self showNavigationInfoView];
            }
        }
        else if ( [[URL absoluteString] hasPrefix:@"architectsdk://markerselected"])
        {
            [self presentPoiDetails:parameters];
        }
    }
}

//从AR点击景点详情 
- (void)presentPoiDetails:(NSDictionary *)poiDetails
{
//    NSString *poiIdentifier = [poiDetails objectForKey:@"id"];
//    NSString *poiName = [poiDetails objectForKey:@"title"];
//    NSString *poiDescription = [poiDetails objectForKey:@"description"];
//    NSString *poiImage = [poiDetails objectForKey:@"image"];
//    
//    WTPoi *poi = [[WTPoi alloc] initWithIdentifier:poiIdentifier location:nil name:poiName detailedDescription:poiDescription image:poiImage];
//    
//    if (poi)
//    {
//        
//        
//        NSString *str = [poi.name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        DLog(@"%@",str);
//        NSLog(@"%@ %@ %@",str,poi.detailedDescription,poi.image);
//        
//        Feature2ViewController *vc = [[Feature2ViewController alloc] init];
//        vc.title = str;
//        vc.url = [NSString stringWithFormat:@"view-%@-",poiDescription];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//        
//        
//    }
    
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] init];
    UIImage *backImage = [UIImage imageNamed:@"navi_back"];
    [backItem setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];//更改背景图片
    self.navigationItem.backBarButtonItem = backItem;
    DetailViewController *vc = [[DetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

/* The debug delegate can be used to respond to internal issues, e.g. the user declined camera or GPS access.
 
 NOTE: The debug delegate method -architectView:didEncounterInternalWarning is currently not used.
 */
#pragma mark WTArchitectViewDebugDelegate
- (void)architectView:(WTArchitectView *)architectView didEncounterInternalWarning:(WTWarning *)warning {
    
    /* Intentionally Left Blank */
}

- (void)architectView:(WTArchitectView *)architectView didEncounterInternalError:(NSError *)error {
    NSLog(@"WTArchitectView encountered an internal error '%@'", [error localizedDescription]);
}

@end