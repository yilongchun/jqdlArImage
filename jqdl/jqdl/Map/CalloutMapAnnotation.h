//
//  CalloutMapAnnotation.h
//  jqdl
//
//  Created by Stephen Chin on 2017/3/20.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface CalloutMapAnnotation : NSObject<BMKAnnotation>

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@property(retain,nonatomic) NSDictionary *locationInfo;//callout吹出框要显示的各信息

- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon;

@end
