//
//  FeatureListViewController.h
//  jqdl
//
//  Created by Stephen Chin on 17/1/6.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureListViewController : UIViewController

@property(strong,nonatomic) NSArray *jingdianArray;
@property (strong, nonatomic) IBOutlet UITableView *mytableview;

@end
