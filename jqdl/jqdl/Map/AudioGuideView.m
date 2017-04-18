//
//  AudioGuideView.m
//  jqdl
//
//  Created by Stephen Chin on 2017/4/18.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "AudioGuideView.h"
#define Arror_height 10
#define Arror_width 8

@implementation AudioGuideView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);//设置线宽
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:95.0/255.0 green:108.0/255.0 blue:123.0/255.0 alpha:1].CGColor);//设置颜色
    [self getDrawPath:context];
    CGContextFillPath(context);//填充
}

//底部中间尖头
- (void)getDrawPath:(CGContextRef)context{
    CGRect rrect = self.bounds;
    CGFloat radius = 4.0;
    CGFloat minx = CGRectGetMinX(rrect),//0
    midx = rrect.size.width - 25,//50
    maxx = CGRectGetMaxX(rrect);//100
    CGFloat miny = CGRectGetMinY(rrect),//0
    //midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;//94
    CGContextMoveToPoint(context, midx+Arror_width, maxy);//设置起始点                CGContextMoveToPoint(context, 50+6, 94);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);//设置下一个坐标点         CGContextAddLineToPoint(context,50, 94+6);
    CGContextAddLineToPoint(context,midx-Arror_width, maxy);//设置下一个坐标点         CGContextAddLineToPoint(context,50-6, 94);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);//绘制弧线         CGContextAddArcToPoint(context, 0, 94, 0, 0, 6.0);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);//绘制弧线         CGContextAddArcToPoint(context, 0, 0, 100, 0, 6.0);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);//绘制弧线          CGContextAddArcToPoint(context, 100, 0, 100, 100, 6.0);
    CGContextAddArcToPoint(context, maxx, maxy, midx+Arror_height, maxy, radius);//绘制弧线          CGContextAddArcToPoint(context, 100, 100, 50, 100, 6.0);
    CGContextClosePath(context);//封闭当前线路
    
}

@end
