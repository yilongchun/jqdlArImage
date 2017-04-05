//
//  PhotoViewController.h
//  jqdl
//
//  Created by Stephen Chin on 2017/4/5.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSArray *images;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end
