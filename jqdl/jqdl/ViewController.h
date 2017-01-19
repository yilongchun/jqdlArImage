//
//  ViewController.h
//  WikitudeTest
//
//  Created by Stephen Chin on 16/9/19.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "CategoryList.h"
#import<CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController{
//    NSMutableArray *jingdianDataSource;
//    CategoryList *categoryList;//景区
    
    
}

//@property (nonatomic, strong) NSArray *beaconArr;//存放扫描到的iBeacon
@property (strong, nonatomic) CLBeaconRegion *beacon1;//被扫描的iBeacon
@property (strong, nonatomic) CLLocationManager * locationmanager;


@end

