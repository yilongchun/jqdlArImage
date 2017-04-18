//
//  PlayButton.m
//  jqdl
//
//  Created by Stephen Chin on 2017/4/7.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "PlayButton.h"

@implementation PlayButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //创建背景
    _BGShapeLayer = [CAShapeLayer layer];   //创建出CAShapeLayer
    _BGShapeLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    //    _BGShapeLayer.position = self.center;
//    _BGShapeLayer.fillColor = [RGB(255, 235, 168) CGColor];  //设置填充颜色
//    _BGShapeLayer.strokeColor = RGB(255, 235, 168).CGColor;
    _BGShapeLayer.fillColor = [UIColor clearColor].CGColor;
    _BGShapeLayer.lineWidth = 3.0f;   //设置线条的宽度和颜色
    //    _BGShapeLayer.strokeStart = 0;    //起始位置
    //    _BGShapeLayer.strokeEnd = 1;     //终点
    
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    //    self.shapeLayer.position = self.center;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayer.lineWidth = 3.0f;
    self.shapeLayer.strokeColor = RGB(255, 196, 0).CGColor;
    self.shapeLayer.strokeStart = 0.0f;
    self.shapeLayer.strokeEnd = 0;
    
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    //创建出圆形贝塞尔曲线
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
    
    _BGShapeLayer.path = circlePath.CGPath;    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = circlePath.CGPath;
    
    [self.layer addSublayer:_BGShapeLayer];  //添加并显示
    [self.layer addSublayer:self.shapeLayer];
}

- (void)setProgress:(float)progress animated:(BOOL)animated{
    if (animated) {
        [CATransaction begin];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [CATransaction setAnimationDuration:0.0];
        self.shapeLayer.strokeEnd = progress;
        [CATransaction commit];
    }else{
        self.shapeLayer.strokeEnd = progress;
    }
    
}


@end