//
//  CallOutAnnotationView.m
//  jqdl
//
//  Created by Stephen Chin on 2017/3/20.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import "CallOutAnnotationView.h"

#define Arror_height 6

@implementation CallOutAnnotationView

@synthesize contentView;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        self.centerOffset = CGPointMake(0, -50);
        self.frame = CGRectMake(0, 0, 44 * 4 + 5 * 3 + 10, 44 + 20);
        UIView *_contentView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-10)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        self.contentView = _contentView;
    } return self;
}

//-(void)drawRect:(CGRect)rect{
////    [self drawInContext:UIGraphicsGetCurrentContext()];
////    self.layer.shadowColor = [[UIColor blackColor] CGColor];
////    self.layer.shadowOpacity = 1.0;
////    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//}

//-(void)drawInContext:(CGContextRef)context {
//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor);
//    [self getDrawPath:context];
//    CGContextFillPath(context);
//}
//
//- (void)getDrawPath:(CGContextRef)context {
//    CGRect rrect = self.bounds;
//    CGFloat radius = 6.0;
//    CGFloat minx = CGRectGetMinX(rrect),
//    midx = CGRectGetMidX(rrect),
//    maxx = CGRectGetMaxX(rrect);
//    CGFloat miny = CGRectGetMinY(rrect),
//    //midy = CGRectGetMidY(rrect),
//    maxy = CGRectGetMaxY(rrect)-Arror_height;
//    CGContextMoveToPoint(context, midx+Arror_height, maxy);
//    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
//    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
//    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
//    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
//    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
//    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
//    CGContextClosePath(context);
//}
@end
