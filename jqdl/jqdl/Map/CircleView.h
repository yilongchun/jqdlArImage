//
//  CircleView.h
//  jqdl
//
//  Created by Stephen Chin on 2017/4/5.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView

@property(nonatomic,retain) CAShapeLayer *shapeLayer;
@property(nonatomic,retain) CAShapeLayer *BGShapeLayer;

- (void)setProgress:(float)progress animated:(BOOL)animated;

-(id)initWithFrame:(CGRect)frame;

-(void)setImage:(UIImage *)image;

@end
