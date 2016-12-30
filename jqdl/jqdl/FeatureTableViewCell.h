//
//  FeatureTableViewCell.h
//  jqdl
//
//  Created by Stephen Chin on 16/12/30.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end
