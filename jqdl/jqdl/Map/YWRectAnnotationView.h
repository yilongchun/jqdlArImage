//
//  YWRectAnnotationView.h
//  jqdl
//
//  Created by Stephen Chin on 2017/4/22.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

@interface YWRectAnnotationView : BMKAnnotationView

@property(nonatomic,copy)UIImageView            *leftImage;
@property(nonatomic,copy)UIImage            *leftHighlightImage;
@property(nonatomic,copy)NSString           *titleText;
@property(nonatomic,copy)UIView                 *contentView;

-(void)setTitleText:(NSString *)titleText leftImage:(UIImage *)image;

@end
