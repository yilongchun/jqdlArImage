//
//  DetailViewController.h
//  WikitudeTest
//
//  Created by Stephen Chin on 16/9/23.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTPoi.h"
#import "Player.h"

@interface DetailViewController : UIViewController

@property (strong,nonatomic) NSDictionary *poi;
@property (strong,nonatomic) NSString *spotId;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end
