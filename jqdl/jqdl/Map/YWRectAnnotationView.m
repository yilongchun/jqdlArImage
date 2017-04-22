//
//  YWRectAnnotationView.m
//  jqdl
//
//  Created by Stephen Chin on 2017/4/22.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "YWRectAnnotationView.h"



@interface YWRectAnnotationView()
{
    UIImageView                     *_leftImage;
    UILabel                     *_titleLable;
    UIView                      *_contentView;
}
@end
@implementation YWRectAnnotationView

-(instancetype)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]){
        [self initMakeSubViews];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)return;
    if (selected)
    {
        [_contentView setBackgroundColor:[ UIColor whiteColor]];
//        [_contentView bringSubviewToFront:_leftImage];
//        [_contentView bringSubviewToFront:_titleLable];
//        [self bringSubviewToFront:_contentView];
//        if (_CalloutView == nil)
//        {
//            _CalloutView = [[YWActionPaopaoView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
//            _CalloutView.center = CGPointMake(CGRectGetWidth(_contentView. bounds) / 2.f + self.calloutOffset.x,-CGRectGetHeight(_CalloutView.bounds) / 2.f + self.calloutOffset.y);
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            btn.frame = CGRectMake(10, 10, 40, 40);
//            [btn setTitle:@"yuwei" forState:UIControlStateNormal];
//            [btn setBackgroundColor:[UIColor whiteColor]];
//            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//            
//            [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 100, 30)];
//            name.backgroundColor = [UIColor clearColor];
//            name.textColor = [UIColor whiteColor];
//            name.text = @"Mr-yuwei";
//            
//            [_CalloutView addSubview:btn];
//            [_CalloutView addSubview:name];
//            
//        }
//        
//        [self addSubview:_CalloutView];
    }
    else
    {
        [_contentView setBackgroundColor:[ UIColor clearColor]];
//        [_CalloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}
//-(void)click{
//    
//    [_CalloutView removeFromSuperview];
//}
-(void)initMakeSubViews{
    //需要根据字数的长度计算宽度
    
    UIView *contentView=[[ UIView alloc] init];
    [contentView setBackgroundColor:[ UIColor clearColor]];
    _contentView=contentView;
    
    UIImageView *imageview = [[UIImageView alloc] init];
    _leftImage = imageview;
    [contentView addSubview:imageview];
    
    UILabel *lable=[[ UILabel alloc] init];
    lable.textColor=[ UIColor blackColor];
    lable.font=[ UIFont systemFontOfSize:13];
    _titleLable=lable;
    [contentView addSubview:lable];
    [self addSubview:contentView];
    
    ViewRadius(_contentView, 15);
    
}

-(void)setTitleText:(NSString *)titleText leftImage:(UIImage *)image{
    
    _titleLable.text=titleText;
    _leftImage.image = image;
    //计算高度
    CGFloat Width = [titleText sizeWithFont:[UIFont systemFontOfSize: 13] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 21) lineBreakMode:NSLineBreakByWordWrapping].width;
    
    
    [_contentView setFrame:CGRectMake(0, 0, 30 + Width+5, 30)];
    [_leftImage setFrame:CGRectMake(2, 2, 26, 26)];
    [_titleLable setFrame:CGRectMake(30,4, Width, 22)];
    
    
    
//    CGRect rect = _contentView.bounds;
//    //创建Path
//    CGMutablePathRef layerpath = CGPathCreateMutable();
//    CGPathMoveToPoint(layerpath, NULL, 0, 0);
//    CGPathAddLineToPoint(layerpath, NULL, CGRectGetMaxX(rect), 0);
//    CGPathAddLineToPoint(layerpath, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
//    
//    CGPathAddLineToPoint(layerpath, NULL, 45, CGRectGetMaxY(rect));
//    CGPathAddLineToPoint(layerpath, NULL, 37.5, CGRectGetMaxY(rect)+5);
//    CGPathAddLineToPoint(layerpath, NULL, 30, CGRectGetMaxY(rect));
//    CGPathAddLineToPoint(layerpath, NULL, 0, CGRectGetMaxY(rect));
//    
//    CAShapeLayer *shapelayer=[CAShapeLayer  layer];
//    UIBezierPath *path=[ UIBezierPath  bezierPathWithCGPath:layerpath];
//    shapelayer.path=path.CGPath;
//    shapelayer.fillColor=[ UIColor colorWithRed:83/255.0 green:180/255.0 blue:119/255.0 alpha:1.0].CGColor;
//    shapelayer.cornerRadius=5;
//    [_contentView.layer addSublayer:shapelayer];
    
    
    [_contentView bringSubviewToFront:_leftImage];
    [_contentView bringSubviewToFront:_titleLable];
    self.bounds=_contentView.bounds;
    
    //销毁Path
//    CGPathRelease(layerpath);
    
    [ self layoutIfNeeded];
    [self setNeedsDisplay];
}
-(void)layoutSubviews{
    
    [ super layoutSubviews];
}

@end
