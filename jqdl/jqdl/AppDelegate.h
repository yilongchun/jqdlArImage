//
//  AppDelegate.h
//  jqdl
//
//  Created by Stephen Chin on 15/11/17.
//  Copyright © 2015年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

