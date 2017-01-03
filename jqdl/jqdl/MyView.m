//
//  MyView.m
//  jqdl
//
//  Created by Stephen Chin on 17/1/3.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "MyView.h"

@implementation MyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    if ([self pointInside:point withEvent:event]) {
//        for (id view in [self subviews]) {
//            DLog(@"%@",[self subviews]);
//            if ([view isKindOfClass:[UIScrollView class]]) {
//                DLog(@"is scrollview");
//                
//                return view;
//            }else{
//                DLog(@"no scrollview");
                return [super hitTest:point withEvent:event];
//            }
//        }
//    }
//    return nil;
}

@end
