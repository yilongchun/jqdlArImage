//
//  DetailViewController.h
//  WikitudeTest
//
//  Created by Stephen Chin on 16/9/23.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTPoi.h"

@interface DetailViewController : UIViewController

@property (strong,nonatomic) WTPoi *poi;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end
