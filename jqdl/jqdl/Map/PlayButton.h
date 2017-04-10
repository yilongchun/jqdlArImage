//
//  PlayButton.h
//  jqdl
//
//  Created by Stephen Chin on 2017/4/7.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKIt/UIKIt.h>

@interface PlayButton : UIButton

@property(nonatomic,retain) CAShapeLayer *shapeLayer;
@property(nonatomic,retain) CAShapeLayer *BGShapeLayer;
@property(nonatomic,retain) NSTimer *timer;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
