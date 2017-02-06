//
//  UserInfoViewController.h
//  qlxing
//
//  Created by Stephen Chin on 16/7/26.
//  Copyright © 2016年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
