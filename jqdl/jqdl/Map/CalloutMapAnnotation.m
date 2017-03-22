//
//  CalloutMapAnnotation.m
//  jqdl
//
//  Created by Stephen Chin on 2017/3/20.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "CalloutMapAnnotation.h"

@implementation CalloutMapAnnotation

@synthesize latitude;
@synthesize longitude;
@synthesize locationInfo;

- (id)initWithLatitude:(CLLocationDegrees)lat andLongitude:(CLLocationDegrees)lon {
    if (self = [super init]) {
        self.latitude = lat;
        self.longitude = lon;
    } return self;
}

-(CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}

@end
