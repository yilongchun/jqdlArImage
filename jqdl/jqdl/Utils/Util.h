//
//  Util.h
//  jqdl
//
//  Created by Stephen Chin on 15/11/25.
//  Copyright © 2015年 Stephen Chin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Util : NSObject

//计算单个文件大小
+(float)fileSizeAtPath:(NSString *)path;

//计算目录大小
+(float)folderSizeAtPath:(NSString *)path;

//清空缓存
+(void)removeCache;

//清空缓存
+(void)deleteAllCache;

//验证手机号
+(BOOL) isValidateMobile:(NSString *)mobile;

+ (NSArray *)getInstalledMapAppWithEndLocation:(CLLocationCoordinate2D)endLocation;

+ (NSString *)uuidString;
@end
