//
//  BMAdScrollView.h
//  UIPageController
//
//  Created by skyming on 14-5-31.
//  Copyright (c) 2014年 Sensoro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMImageView : UIImageView

@end

/**
 *  @Class  BMBannerView
 */

// 广告位点击事件协议
@protocol BannerClickEventDelegate <NSObject>
- (void)bannerClickAt:(NSInteger)idx;
@end

@interface BMBannerView : UIView

@property(nonatomic, getter=isTitleHidden) BOOL titleHidden; // 是否隐藏标题
@property(nonatomic, weak)id<BannerClickEventDelegate> delegate;

/**
 *  @method initWithImageName: title: x: tFrame: iHeight: titleHidden:
 *
 *  @param imageURL        图片URL
 *  @param title           标题文字
 *  @param isTitleHidden  标题是否隐藏
 *
 *  @discussion  当标题隐藏时注意pageControl 位置的调整(titleFrame)
 */
-(instancetype)initWithFrame:(CGRect)frame ImageName:(NSString *)imageURL title:(NSString *)title;
@end



/**
 *  @Class  BMAdScrollView
 */

// 点击中的图片点击事件协议
@protocol ImageClickEventDelegate <NSObject>
-(void)imageClickAt:(NSInteger)vid;
@end

@interface BMAdScrollView : UIView

@property (nonatomic, strong) NSArray *images;          // 图片
@property (nonatomic, strong) NSArray *titles;          // 文字

@property (nonatomic) CGFloat height;                   // 广告栏高度
@property (nonatomic) CGFloat offsetY;                  // 广告栏偏移量
@property (nonatomic) CGPoint pageCenter;               // 分页中心点

@property (nonatomic, strong) UIColor *titleColor;       // 文字标题颜色
@property (nonatomic, strong) NSTimer *timer;            // 不要忘记 Valid
@property (nonatomic, weak)   id<ImageClickEventDelegate> delegate;

/**
 *  @method initWithNameArr: titleArr: height:
 *
 *  @param imageArr       图片数组
 *  @param titleArr       标题数组
 *
 *  @discussion     默认首页为零，当视图出现或消失时，注意对timer的处理
 */
- (instancetype)initWithFrame:(CGRect)frame images:(NSMutableArray *)imageURLs titles:(NSMutableArray *)titles;

@end
