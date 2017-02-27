//
//  ValidatePhoneViewController.h
//  jqdl
//
//  Created by Stephen Chin on 17/2/24.
//  Copyright © 2017年 Stephen Chin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ValidatePhoneViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *code;

@end
