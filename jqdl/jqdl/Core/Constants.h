//
//  Constants.h
//  impi
//
//  Created by Chris on 15/3/21.
//  Copyright (c) 2015年 Zoimedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ResultCodeType){
    ResultCodeSuccess = 200,//操作成功
    ResultCodeFileTooLarge = 201,//上传文件超过大小
    ResultCodeInvalidParam = 202,//参数错误
    ResultCodeNoData = 203,//查询不到结果
    ResultCodeFail = 502//操作失败
};

#define DEFAULT_TEXT_COLOR RGB(20,205,222)
#define DEFAULT_BACKGROUND_COLOR RGB(66,216,230)

//已登录用户
#define LOGINED_USER @"loginedUser"
//用户信息
#define USER_INFO @"kUserInfo"


#define kBaiduAK @"y63FqvA3ResevIFcSQMbTmOIFdLIXP5D"

//#define kHost @"http://g.ticket168.com/"


//三游洞
#define STORE_ID @"f66c0fc1f74580c525365751a9ce21b6"

/***************** API ***************/

//测试服务器
#define kHost @"https://api.qlxing.com"
//正式服务器
//#define kHost @"https://api.zlyun168.com"

#define kVERSION @"/v2"

//获取七牛上传token
#define API_QINIU_UPTOKEN @"/third_party/qiniu/uptoken"
//七牛上传文件
#define API_QINIU_UPLOAD @"http://upload.qiniu.com/"


/**
 *  当前用户相关
 */
#define API_USERS_CURRENT @"/users/current"

/**
 *  auth
 */
////登录
//#define API_AUTH_LOGIN @"/login"
////验证码登录
//#define API_AUTH_LOGIN_CODE @"/login/code"
//注册
#define API_AUTH_REGISTER @"/register"
//重置密码
#define API_AUTH_RESETPWD @"/reset_password"
//发送注册验证码
#define API_AUTH_CODE_REGISTER @"/code/register"
//发送登录验证码
#define API_AUTH_CODE_LOGIN @"/code/login"
//发送重置密码验证码
#define API_AUTH_CODE_RESETPWD @"/code/reset_password"

/**
 *  西陵峡
 */
//#define kHost @"http://192.168.10.30:8080/"
////#define kHost @"http://www.wxin168.com:8082/"//可以去掉了

//手绘地图
//#define MAP_NAME @"xilingxia"
//手绘地图经纬度
//#define OVERLAY1_X 30.774615
//#define OVERLAY1_Y 111.258972
//#define OVERLAY2_X 30.760523
//#define OVERLAY2_Y 111.279458
////景区列表
//#define API_CATEGORY_LIST @"X002/category/list.c"
////景点列表
//#define API_JINGDIAN_LIST @"X002/category/childList.c"
////景点介绍
//#define API_JINGDIAN_DETAIL @"X002/article/list.c"
////景点详情
//#define API_VIEW @"X002/"
////攻略
//#define API_GONGLUE @"X002/category/lists?type=3"
////意见反馈
//#define API_FEEDBACK @"X002/feedBack/save.c"

/**
 *  狮子关
 */
//手绘地图
#define MAP_NAME @"szg"
//手绘地图经纬度
#define OVERLAY1_Y 109.559000
#define OVERLAY1_X 29.975000
#define OVERLAY2_Y 109.565000
#define OVERLAY2_X 29.971000
//景区列表
#define API_CATEGORY_LIST @"X001/category/list.c"
//景点列表
#define API_JINGDIAN_LIST @"X001/category/childList.c"
//景点介绍
#define API_JINGDIAN_DETAIL @"X001/article/list.c"
//景点详情
#define API_VIEW @"X001/"
//攻略
#define API_GONGLUE @"X001/category/lists?type=3"
//意见反馈
#define API_FEEDBACK @"X001/feedBack/save.c"




#define NAVIGATION_BAR_COLOR RGB(52,170,235)
#define BACKGROUND_COLOR RGB(235,235,235)

@interface Constants : NSObject


@end
