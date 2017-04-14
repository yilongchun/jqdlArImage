//
//  MapSpotTableViewCell.h
//  jqdl
//
//  Created by Stephen Chin on 2017/4/14.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapSpotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *spotTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
