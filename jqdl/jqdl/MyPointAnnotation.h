//
//  MyPointAnnotation.h
//  jqdl
//
//  Created by Stephen Chin on 16/12/30.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CLLocation.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "WTPoi.h"

@interface MyPointAnnotation : BMKPointAnnotation

@property(strong,nonatomic) WTPoi *poi;

@end
