//
//  WTPoi.h
//  WTSimpleARBrowserExample
//
//  Created by Andreas Schacherbauer on 1/23/12.
//  Copyright (c) 2012 Wikitude GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>



@class CLLocation;

@interface WTPoi : NSObject

@property (nonatomic, assign) NSString                      *identifier;
@property (nonatomic, assign) NSString                      *ids;
@property (nonatomic, strong) CLLocation                    *location;
@property (nonatomic, retain) NSString                      *name;
@property (nonatomic, retain) NSString                      *detailedDescription;
@property (nonatomic, retain) NSString                      *image;
@property (nonatomic, retain) NSString                      *images;
@property (nonatomic, retain) NSString                      *voice;
@property (nonatomic, retain) NSString                      *address;
@property (nonatomic, retain) NSString                      *type;

//+ (WTPoi *)poiWithIdentifier:(NSString *)identifier location:(CLLocation *)location name:(NSString *)name detailedDescription:(NSString *)detailedDescription;

- (instancetype)initWithIdentifier:(NSString *)identifier ids:(NSString *)ids location:(CLLocation *)location name:(NSString *)name detailedDescription:(NSString *)detailedDescription image:(NSString *)image images:(NSString *)images voice:(NSString *)voice address:(NSString *)address type:(NSString *)type;


- (NSDictionary*)jsonRepresentation;

@end
