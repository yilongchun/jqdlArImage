//
//  MyView.m
//  jqdl
//
//  Created by Stephen Chin on 2017/3/24.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "MyView2.h"
#define Arror_height 10

@implementation MyView2

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);//设置线宽
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor);//设置颜色
    [self getDrawPath:context];
    CGContextFillPath(context);//填充
    //阴影
//    self.layer.shadowColor = [RGBA(0, 0, 0, 0.2) CGColor];
//    self.layer.shadowOpacity = 1.0;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

//底部中间尖头
- (void)getDrawPath:(CGContextRef)context{
    CGRect rrect = self.bounds;
    CGFloat radius = 4.0;
    CGFloat minx = CGRectGetMinX(rrect),//0
    midx = CGRectGetMidX(rrect),//50
    maxx = CGRectGetMaxX(rrect);//100
    CGFloat miny = CGRectGetMinY(rrect),//0
    //midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;//94
    CGContextMoveToPoint(context, midx+Arror_height, maxy);//设置起始点                CGContextMoveToPoint(context, 50+6, 94);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);//设置下一个坐标点         CGContextAddLineToPoint(context,50, 94+6);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);//设置下一个坐标点         CGContextAddLineToPoint(context,50-6, 94);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);//绘制弧线         CGContextAddArcToPoint(context, 0, 94, 0, 0, 6.0);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);//绘制弧线         CGContextAddArcToPoint(context, 0, 0, 100, 0, 6.0);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);//绘制弧线          CGContextAddArcToPoint(context, 100, 0, 100, 100, 6.0);
    CGContextAddArcToPoint(context, maxx, maxy, midx+Arror_height, maxy, radius);//绘制弧线          CGContextAddArcToPoint(context, 100, 100, 50, 100, 6.0);
    CGContextClosePath(context);//封闭当前线路
}
//顶部右边尖头
- (void)getDrawPath2:(CGContextRef)context{
    CGRect rrect = self.bounds;
    CGFloat radius = 2.0;
    CGFloat minx = CGRectGetMinX(rrect),
    maxx = CGRectGetMaxX(rrect),
    midx = maxx - 15;
    CGFloat miny = CGRectGetMinY(rrect)+Arror_height,
    //midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, midx-Arror_height, miny);//50-6,6
    CGContextAddLineToPoint(context,midx, miny-Arror_height);//50,0
    CGContextAddLineToPoint(context,midx+Arror_height, miny);//50+6,6
//    CGContextAddLineToPoint(context,maxx, miny);
//    CGContextAddLineToPoint(context,maxx, maxx);
//    CGContextAddLineToPoint(context,minx, maxy);
//    CGContextAddLineToPoint(context,minx, miny);

    
    
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, minx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, miny, midx-Arror_height, miny, radius);
    CGContextClosePath(context);
}

@end
