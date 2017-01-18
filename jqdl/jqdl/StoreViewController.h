//
//  StoreViewController.h
//  jqdl
//
//  Created by Stephen Chin on 17/1/18.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTPoi.h"

@interface StoreViewController : UIViewController

@property (strong,nonatomic) WTPoi *poi;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end
