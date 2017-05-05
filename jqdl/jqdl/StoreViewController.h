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

@property (strong,nonatomic) NSDictionary *poi;
@property (strong,nonatomic) NSString *storeId;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end
