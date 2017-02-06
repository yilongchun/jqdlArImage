//
//  UserInfoTableViewCell.h
//  qlxing
//
//  Created by Stephen Chin on 16/7/27.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *myTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *myTextField;

@end
