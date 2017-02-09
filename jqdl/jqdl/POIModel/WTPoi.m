//
//  WTPoi.m
//  WTSimpleARBrowserExample
//
//  Created by Andreas Schacherbauer on 1/23/12.
//  Copyright (c) 2012 Wikitude GmbH. All rights reserved.
//

#import "WTPoi.h"

#import <CoreLocation/CoreLocation.h>



@implementation WTPoi


//+ (WTPoi *)poiWithIdentifier:(NSString *)identifier location:(CLLocation *)location name:(NSString *)name detailedDescription:(NSString *)detailedDescription
//{
//    WTPoi *poi = nil;
//    
//    if ( identifier
//         &&
//         location
//         &&
//         name
//         &&
//         detailedDescription
//        )
//    {
//        poi = [[WTPoi alloc] initWithIdentifier:identifier location:location name:name detailedDescription:detailedDescription image:@"" voice:@""];
//    }
//    
//    return poi;
//}

- (instancetype)initWithIdentifier:(NSString *)identifier location:(CLLocation *)location name:(NSString *)name detailedDescription:(NSString *)detailedDescription image:(NSString *)image images:(NSString *)images voice:(NSString *)voice address:(NSString *)address type:(NSString *)type
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _location = location;
        _name = name;
        _detailedDescription = detailedDescription;
        _image = image;
        _images = images;
        _voice = voice;
        _address = address;
        _type = type;
    }    
    return self;
}



- (NSDictionary*)jsonRepresentation
{
    NSArray *poiObjects = @[self.identifier,
                            @(self.location.coordinate.latitude),
                            @(self.location.coordinate.longitude),
                            @(self.location.altitude),
                            self.name,
                            self.detailedDescription,
                            self.image,
                            self.images,
                            self.voice,
                            self.address,
                            self.type
                            ];
    
    NSArray *poiKeys = @[@"id",
                         @"latitude",
                         @"longitude",
                         @"altitude",
                         @"name",
                         @"description",
                         @"image",
                         @"images",
                         @"voice",
                         @"address",
                         @"type"];

    NSDictionary *jsonRepresentation = [NSDictionary dictionaryWithObjects:poiObjects forKeys:poiKeys];

    return jsonRepresentation;
}

@end
